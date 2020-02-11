
module SDRAM_Controller(	
	//--INTERFACE INPUT.  These control if we read or write.
	input wire reset_n , //Active low reset
	input wire activeClock, //143Mhz clock
	input reg [24:0] address, //BANK (2) , Row (13) , Collumn (10)   
	input wire [15:0] inputData, //Data to be written into the address 
	input wire isWriting, //High when the command is to write to that address.  Low when you wish to read from the address
	input wire inputValid, //Pulsed high when input is valid.  Begin command. 
	
	//--INTERFACE OUTPUT.  These give output from read and other signals.
	output wire [15:0] outputData, //Data that has been read from the address
	output reg outputValid, //Pulsed high when output is valid.  Ready for new command.
	output wire isBusy, //Goes high when performing an action to include AutoRefresh.
	output reg recievedCommand, //Used to indicate if a command was recieved.  Pulsed high before returning to low.
	output wire [15:0] debugOutputData, 
	
	//-------------------------
	//--Hardware interface Pins
	output wire max10Board_SDRAM_Clock, 
    output wire max10Board_SDRAM_ClockEnable, 
    output reg [12: 0]   max10Board_SDRAM_Address, 
    output reg [ 1: 0]   max10Board_SDRAM_BankAddress,
    inout  reg [15: 0]   max10Board_SDRAM_Data,
    output wire max10Board_SDRAM_DataMask0,
    output wire max10Board_SDRAM_DataMask1,
    output reg max10Board_SDRAM_ChipSelect_n,
    output reg max10Board_SDRAM_WriteEnable_n,
    output reg max10Board_SDRAM_ColumnAddressStrobe_n,
    output reg max10Board_SDRAM_RowAddressStrobe_n
	);

	
	//-------------------------------------
	//---------- COMBINATIONAL ------------
	//-------------------------------------
	assign debugOutputData = isBusy ? inputData : 16'd0; //Currently mostly unused.  Lets us easily port information out.
	
	wire isBusy_AutoRefresh ;  //Does an autorefresh need to occur
	reg isBusy_Command; //is it busy due to a current command.  
	assign isBusy_AutoRefresh = (autorefreshCounter >= 11'd1050) ? 1'b1 : 1'b0;
	assign isBusy = isBusy_AutoRefresh || isBusy_Command; //Combine busy signals into 1 for interface output.

	assign outputData = outputValid ? max10Board_SDRAM_Data : 16'hZZZZ; //Ensures anything outside this is getting the data at the right time.  
	
	//------- FPGA Hardware Pins ---------
	//Data mask allows reading and writing when both are set to logic low. 
	assign max10Board_SDRAM_DataMask0 = 1'b0;
	assign max10Board_SDRAM_DataMask1 = 1'b0;
	//Always have this high.
	assign max10Board_SDRAM_ClockEnable = 1'b1;
	//Data clock always active. 
	assign max10Board_SDRAM_Clock = activeClock;
	
	//-------------------------------------
	//------- STATIC PARAMETERS -----------
	//-------------------------------------
	//--HARDWARE CONTROL PINS : currentCommand
		//This assigns each of these single bit values from curret command.  Sort of like saying chipSelect = currentCommand[3]
		reg [3:0] currentCommand ;
		assign {max10Board_SDRAM_ChipSelect_n, max10Board_SDRAM_RowAddressStrobe_n, max10Board_SDRAM_ColumnAddressStrobe_n, max10Board_SDRAM_WriteEnable_n } = currentCommand;
	
		localparam CMD_UNSELECTED           = 4'b1000; //Device Deselected.  
		localparam CMD_NOP                  = 4'b0111; //No Operation.  Banks : X  A10 : X  Address:X
		localparam CMD_LOADMODE				= 4'b0000; //MRS			Banks : L  A10 : L  Address:V
		//--
		localparam CMD_BANKACTIVATE         = 4'b0011; //ACT            Banks : V  A10 : V  Address:V
		//--
		localparam CMD_READ                 = 4'b0101; //               Banks : V  A10 : L  Address:V
		localparam CMD_READ_AUTOPRECHARGE   = 4'b0101; //               Banks : V  A10 : H  Address:V
		//--
		localparam CMD_WRITE                = 4'b0100; //               Banks : V  A10 : L  Address:V
		localparam CMD_WRITE_AUTOPRECHARGE  = 4'b0100; //               Banks : V  A10 : H  Address:V  
		//--
		localparam CMD_PRECHARGE_SELECTBANK = 4'b0010; //PRE            Banks : V  A10 : L  Address:X
		localparam CMD_PRECHARGE_ALLBANKS   = 4'b0010; //PALL           Banks : X  A10 : H  Address:X
		//--	
		localparam CMD_CBR_AUTOREFRESH      = 4'b0001; //REF            Banks : X  A10 : X  Address:X
		localparam CMD_SELFREFRESH          = 4'b0001; //SELF           Banks : X  A10 : X  Address:X
		//-------------------------------------
	
	//--STATE MACHINE
		reg [4:0] currentState ;
		//--
		localparam INIT = 4'd0; //Leads to next. Initializes some values.
		localparam INIT_STARTUPWAIT = 4'd1; //Wait phase.  Exits when enough clicks have passed.
		localparam INIT_PRECHARGE = 4'd2; //Precharges all banks. Initalizes loop for auto refrehs. Goes to next.
		localparam INIT_AUTOREFRESH = 4'd3; //Autofreshes 8 times. Goes to next.
		localparam INIT_LOADMODE = 4'd4; //Exits to idle state
		//--
		localparam IDLE = 4'd5; //Waits for command
		localparam AUTOFRESH_ALL = 4'd6;  //Sent here from idle after a period of time
		//--
		localparam READ_ROWACTIVATE = 4'd7; //Read command recieved.  Goes to next.
		localparam READ_ACTION = 4'd8; //Actual data becomes available. Goes to next.
		localparam READ_DATAAVAILABLE = 4'd9; //Ends read.  Goes to IDLE
		localparam READ_PRECHARGE = 4'd10; //Ends read.  Goes to IDLE
		//--
		localparam WRITE_ROWACTIVATE = 4'd11; //Write command recieved.  Goes to next.
		localparam WRITE_ACTION = 4'd12; //Actual write to memory.
		localparam WRITE_PRECHARGE = 4'd13; //Ends write.  Goes to IDLE
	//--------------------------------------------------------------
	
	//-------------------------------------
	//-------- Counters & Misc-------------
	//-------------------------------------
	reg [10:0] autorefreshCounter ; //Increments each clock and counts to 1050.  At this point we should perform a single autorefresh.
	reg [16:0] pauseCycles; //clock cycles to pause in the current state
	
	//--------------------------------------------------------------
	//--When we begin a command, we store the input address and data. 
	reg [24:0] inputStoredAddress; 
	reg [15:0] inputStoredData;
	//--------------------------------------------------------------
	 
	 
	 //Done with seutp.  Now state machine.
	 //This state machine is excessively verbose.  It tracks each stage of what the SDRAM controller should be doing.
	 //Orignal intention was that this would be easier to learn from compared to a lot of the controller examples on the internet.
	 
	 
	 
	//--------------------------------------------------------------
	//--STATE MACHINE CONTROL. currentState determines which state//action we are doing.  These states will change pins as it sees fit.
	//--------------------------------------------------------------
	always @(posedge max10Board_SDRAM_Clock) begin
			//Activation // Reset
			if (reset_n == 1'b0) begin
				currentCommand = CMD_NOP;
				currentState <= INIT;
				//Basic state on setup
				recievedCommand = 1'b0;
				max10Board_SDRAM_Address = 13'd0;
				max10Board_SDRAM_BankAddress = 2'd0;
				max10Board_SDRAM_Data = 16'hZZZZ;
				isBusy_Command = 1'b1;
				outputValid = 1'b0;
				pauseCycles = 17'd0;
				//recievedCommand = 16'd0;
				autorefreshCounter = 11'd0;
				inputStoredAddress = 25'd0;
				inputStoredData = 16'd0;
			end 
			else begin
			//State machine 
				case(currentState)
				INIT: begin //0
					currentCommand = CMD_NOP;
						max10Board_SDRAM_Address 	 = 13'b0_000_000_000_000;
						max10Board_SDRAM_BankAddress = 2'b00;
						max10Board_SDRAM_Data	 = 16'hZZZZ;

					isBusy_Command = 1'b1;
					outputValid = 1'b0;
					pauseCycles = 17'd0; //Set to wait 200us on a 143Mhz clock (7ns period)
					currentState <= INIT_STARTUPWAIT; 
				end

				//--------------------------
				INIT_STARTUPWAIT: begin //1
					//Wait for 200ms
					if (pauseCycles != 17'd28600) begin 
						currentCommand = CMD_NOP;
						pauseCycles = pauseCycles + 17'd1;
					end
					//If we have reached the proper amount, prepare for next state.
					else begin
						currentState <= INIT_PRECHARGE;
						//Set up next state
						currentCommand = CMD_PRECHARGE_ALLBANKS;
						max10Board_SDRAM_Address = 13'b0_010_000_000_000;  //address[10] set high for all banks
						pauseCycles = 0; //Precharge will need to wait 3 cycles.
					end
				end

				//--------------------------
				INIT_PRECHARGE: begin //2
					if (pauseCycles != 3) begin //Wait for tRP (15ns)
						currentCommand = CMD_NOP; 
						pauseCycles = pauseCycles + 17'd1;
					end
					else begin
						currentState <= INIT_AUTOREFRESH;
						currentCommand = CMD_CBR_AUTOREFRESH;
						max10Board_SDRAM_Address = 13'b0_000_000_000_000; 
						pauseCycles = 17'd0; //8x auto refresh cycles.  Each auto refresh cycle takes tRC (60ns or 9 clicks) so 72 total
					end
				end
				
				//--------------------------
				INIT_AUTOREFRESH: begin //3
				
					
					if (pauseCycles == 17'd72) begin //8 autorefresh cycles which take 9 clocks each
						currentState <= INIT_LOADMODE;
						pauseCycles = 17'd0; //Loadmode takes 2 cycles, but we use 4 as it's recommended
						
						currentCommand = CMD_LOADMODE;
						max10Board_SDRAM_Address = 13'b000_1_00_011_0_000;
											//A12-A10 : RESERVED//000
											//A9 : Write Burst Mode // 1 (single location)
											//A8-A7 : Operating Mode // 00
											//A6-A4 : Latency Mode CAS 3 // 011
											//A3 : Burst Type  Sequential // 0
											//A2-A0 : Burst Length // 000
					end
					else begin
						//Need 8x autorefresh cycles.  Each cycles requires 63ns (9 clock periods) to be good. 
							//0 (give command)
							//1  0 COMMAND
							//2  1
							//3  2
							//4  3
							//5  4
							//6  5
							//7  6
							//8  7
							//9   8(give command)
							//10   9COMMAND
						//Each autorefresh needs their pins set, but afterwards their pins need to go to nop. 
						if (pauseCycles == 0 || pauseCycles == 9 || pauseCycles == 18 || pauseCycles == 27 || pauseCycles == 36 || pauseCycles == 45
						||pauseCycles == 54 || pauseCycles == 63 )begin
								currentCommand = CMD_CBR_AUTOREFRESH;
								pauseCycles = pauseCycles + 17'b1;
						  end
						  else begin
							currentCommand = CMD_NOP;
							pauseCycles = pauseCycles + 17'b1;
						  end
					end //Else for cycle count
				end //Sate : INIT_AUTOREFRESH

				//--------------------------
				INIT_LOADMODE: begin //4
					if (pauseCycles == 17'd3) begin
						currentState <= IDLE;
						isBusy_Command = 1'b0; 
						pauseCycles = 17'd0; 
					end
					else begin
						currentCommand = CMD_NOP;
						pauseCycles = pauseCycles + 17'd1;
					end
				end
				
				//--------------------------
				//----- IDLE STATE ---------
				//--------------------------
				IDLE: begin //5
					//We recieved a command while not busy.  
					 if (inputValid == 1'b1 && isBusy == 1'b0 )begin
						//Ensure the current input data is stored.  Lets us safely use it later.
						inputStoredAddress = address;
						inputStoredData = inputData;
						
						currentCommand = CMD_BANKACTIVATE;
						max10Board_SDRAM_Address 	 =  address[22:10] ; //Get the 13 values for the ROW.
						max10Board_SDRAM_BankAddress = address[24:23] ; //BANK
						max10Board_SDRAM_Data	 = 16'hZZZZ;
						isBusy_Command = 1'b1; 
						pauseCycles = 17'd0;
						recievedCommand = 1'd1;
						//READ command
						if (isWriting == 1'b0 ) begin
							currentState <= READ_ROWACTIVATE;
						end
						//WRITE command
						else begin
							currentState <= WRITE_ROWACTIVATE;
						end
					end
					//If we are not recieving a command and aren't busy, check if it's time for autorefresh
					else if (isBusy_AutoRefresh == 1'b1 ) begin
						currentState <= AUTOFRESH_ALL;
						currentCommand = CMD_CBR_AUTOREFRESH;
						pauseCycles = 17'd0;
					end
					//We are staying idle. 
					else begin
						currentCommand = CMD_NOP;
						max10Board_SDRAM_Address 	 =  13'b0_000_000_000_000 ;
						max10Board_SDRAM_BankAddress =  2'b00 ;
						max10Board_SDRAM_Data	 = 16'hZZZZ;

						outputValid = 1'b0;
					
						isBusy_Command = 1'b0; 
						inputStoredAddress = 25'd0;
						recievedCommand = 1'd0;
					end
				end
				
				//--------------------------
				//----- AUTO REFRESH -------
				//--------------------------
				AUTOFRESH_ALL: begin //6
					if (pauseCycles == 17'd9) begin
						currentState <= IDLE;
						autorefreshCounter = 11'd0;
						pauseCycles = 17'd0; 
					end
					else begin
						currentCommand = CMD_NOP;
						pauseCycles = pauseCycles + 1'd1;
					end
				end
				
				//--------------------------
				//----- READ STATE ---------
				//--------------------------
				READ_ROWACTIVATE: begin //7
					if (pauseCycles == 17'd2) begin //Reached end of row activation, continue to read action.
						currentState <= READ_ACTION;

						currentCommand = CMD_READ;
						max10Board_SDRAM_Address = {2'b00, 1'b0 , inputStoredAddress[9:0] };  //A10 is low to disable autoprecharge.  First two bits are ignored.  Last 10 bits are COLLUMN
						pauseCycles = 17'd0; //3 works.   8 returns correct value???
					end
					else begin
						recievedCommand = 1'b0;
						currentCommand = CMD_NOP;
						pauseCycles = pauseCycles + 17'd1;
					end
				end
				
				//--------------------------
				READ_ACTION: begin //8
					if (pauseCycles == 17'd2) begin
						currentState <= READ_PRECHARGE;
						pauseCycles = 17'd0; 
						currentCommand = CMD_PRECHARGE_SELECTBANK;
						max10Board_SDRAM_Address = {2'b0, 1'b0 , 10'b0_000_000_000 };  //A10 is low for single bank
					end
					else begin
						currentCommand = CMD_NOP;
						pauseCycles = pauseCycles + 17'd1;
					end
				end
				
				//--------------------------
				READ_PRECHARGE: begin //10
					//DATA is available during the next clock, but not after.
					if (pauseCycles == 17'd0) begin
						outputValid = 1'b1;
						isBusy_Command = 1'b0; //Due to delays, set this low early.
						pauseCycles = pauseCycles + 1'd1;
						currentCommand = CMD_NOP;
					end
					else if (pauseCycles == 17'd2) begin 
						currentState <= IDLE;
						pauseCycles = 17'd0; 
					end
					else begin
						outputValid = 1'b0; 
						pauseCycles = pauseCycles + 17'd1;
					end
				end
				
				//--------------------------
				//----- WRITE STATE --------
				//--------------------------
				//--------------------------
				WRITE_ROWACTIVATE: begin //11
					if (pauseCycles == 17'd2) begin //Reached end of row activation, continue to read action.
						currentState <= WRITE_ACTION;
						pauseCycles = 17'd0; 
						currentCommand = CMD_WRITE;
						max10Board_SDRAM_Address 	 = {2'b00, 1'b0 , inputStoredAddress[9:0] };  //A10 is low to disable autoprecharge.  First two bits are ignored.
					end
					else begin
						currentCommand = CMD_NOP;
						pauseCycles = pauseCycles + 17'd1;
						max10Board_SDRAM_Data = inputStoredData; //Tell it to write early
						recievedCommand = 1'b0;
					end
				end
				
				//--------------------------
				WRITE_ACTION: begin //12
					if (pauseCycles == 17'd2) begin //Reached end of row activation, continue to read action.
						currentState <= WRITE_PRECHARGE;
						pauseCycles = 17'd0; 
						currentCommand = CMD_PRECHARGE_SELECTBANK;
						max10Board_SDRAM_Address = {2'b0, 1'b0 , 10'd0 };  //A10 is low for single bank
						max10Board_SDRAM_Data = 16'hZZZZ; 
					end
					else begin
						currentCommand = CMD_NOP;
						pauseCycles = pauseCycles + 17'd1;
					end
				end
	
				//--------------------------				
				WRITE_PRECHARGE: begin //13
					if (pauseCycles == 17'd2) begin 
						currentState <= IDLE;
						pauseCycles = 17'd0; 
					end
					else begin
						currentCommand = CMD_NOP;
						//Read is no longer valid.
						isBusy_Command <= 1'b0; 
						pauseCycles = pauseCycles + 17'd1;
					end
				end
				
				default : begin
					//Should not happen.  Return state to idle.
					currentState = INIT;
				end
			endcase
			//At end of state machine, increment autoRefreshCounter.
			autorefreshCounter = autorefreshCounter + 1'd1;
		end
	 end //posedge max10Board_SDRAM_Clock
endmodule
