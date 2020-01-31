
//==========================================
//====== ECE 342 JUNIOR DEISGN - W20 - MUSIC BOX
//====== 	Authors : Graham Mueller muellegr@oregonstate.edu
//======

module MusicBox_Main(
	max10Board_Buttons,
	max10board_switches,
	
	max10Board_50MhzClock,
	max10Board_LEDSegments,
	max10Board_LED,
	max10Board_SDRAM_Clock,
	max10Board_SDRAM_ClockEnable,
	max10Board_SDRAM_Address,
	max10Board_SDRAM_BankAddress,
	max10Board_SDRAM_Data,
	max10Board_SDRAM_DataMask0,
	max10Board_SDRAM_DataMask1,
	max10Board_SDRAM_ChipSelect_n,
	max10Board_SDRAM_WriteEnable_n,
	max10Board_SDRAM_ColumnAddressStrobe_n,
	max10Board_SDRAM_RowAddressStrobe_n,
	
	max10Board_GPIO_Input_MusicKeys, //Array
	max10Board_GPIO_Input_PlaySong1,
	max10Board_GPIO_Input_PlaySong0,
	max10Board_GPIO_Input_MakeRecording,
	max10Board_GPIO_Input_PlayRecording,
	
	max10Board_GPIO_Output_SPI_SCLK,
	max10Board_GPIO_Output_SPI_SYNC_n,
	max10Board_GPIO_Output_SPI_DIN
);
	input wire	max10Board_50MhzClock;
	output wire	[5:0][6:0]	max10Board_LEDSegments;//The DE-10 Board LED Segments
	output reg [9:0] max10Board_LED; //The DE-10 Board LED lights
	
	///////// UI GPIO ///////
	input wire [5:0] max10Board_GPIO_Input_MusicKeys; //Array
	input wire max10Board_GPIO_Input_PlaySong1;
	input wire max10Board_GPIO_Input_PlaySong0;
	input wire max10Board_GPIO_Input_MakeRecording;
	input wire max10Board_GPIO_Input_PlayRecording;
	
	///////// GPIO SPI Output to Dac
	output wire max10Board_GPIO_Output_SPI_SCLK; //Data clock per bit
	output wire max10Board_GPIO_Output_SPI_SYNC_n; //Low when sending data
	output wire max10Board_GPIO_Output_SPI_DIN; //Data bits
	///////// SDRAM /////////
	output wire max10Board_SDRAM_Clock;
	output wire max10Board_SDRAM_ClockEnable;
	output wire [12: 0]   max10Board_SDRAM_Address;
	output wire [ 1: 0]   max10Board_SDRAM_BankAddress;
	inout wire [15: 0]   max10Board_SDRAM_Data;
	input wire [9:0] max10board_switches;
	
	output wire max10Board_SDRAM_DataMask0;
	output wire max10Board_SDRAM_DataMask1;
	output wire max10Board_SDRAM_ChipSelect_n; //active low
	output wire max10Board_SDRAM_WriteEnable_n; //active low
	output wire max10Board_SDRAM_ColumnAddressStrobe_n; //active low
	output wire max10Board_SDRAM_RowAddressStrobe_n; //active low
	/////////////////////////////////////////////////////////
	//-- 
	input wire	[1: 0] max10Board_Buttons ;









	//-------------------------
	//-----Major Variables-----
	//-------------------------
	wire systemReset_n = max10Board_Buttons[0]; //Currently all systems should reset on this. 
	
	
	//-----------------------
	//--MISC CLOCK GENERATORS
	wire CLK_100hz ;
	ClockGenerator clockGenerator_100hz (
		.inputClock(max10Board_50MhzClock),
		.reset_n(systemReset_n),
		.outputClock(CLK_100hz)
	);
		defparam	clockGenerator_1Khz.BitsNeeded = 25; //Must be able to count up to InputClockEdgesToCount.  
		defparam	clockGenerator_1Khz.InputClockEdgesToCount = 250000;
	
	
	//-----------------------
	//--MISC CLOCK GENERATORS
	wire CLK_1Khz ;
	ClockGenerator clockGenerator_1Khz (
		.inputClock(max10Board_50MhzClock),
		.reset_n(systemReset_n),
		.outputClock(CLK_1Khz)
	);
		defparam	clockGenerator_1Khz.BitsNeeded = 15; //Must be able to count up to InputClockEdgesToCount.  
		defparam	clockGenerator_1Khz.InputClockEdgesToCount = 25000;
	
	wire CLK_1Hz ;
	ClockGenerator clockGenerator_1hz (
		.inputClock(CLK_1Khz),
		.reset_n(systemReset_n),
		.outputClock(CLK_1Hz)
	);
		defparam	clockGenerator_1hz.BitsNeeded = 10; //Must be able to count up to InputClockEdgesToCount.  
		defparam	clockGenerator_1hz.InputClockEdgesToCount = 500;
	
	
	
	//----------------------------
	//-- MAIN MODULE CONTROLLER---
	//----------------------------
	wire [4:0] outputCurrentState;
	wire [31:0] output_DebugString; 
	
	
	
	
	//----------------------------
	//-- INPUT SMOOTHING----------
	//----------------------------
	//These take the hardware IO and smooth it out over 1ms.
		//These assume active low.
	wire [5:0] max10Board_GPIO_Input_MusicKeys_s; //Array
		UI_TriggerSmoother UIs_MusicKeys0 (
			.clock_50Mhz(max10Board_50MhzClock),
			.inputWire(max10Board_GPIO_Input_MusicKeys[0]),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_MusicKeys_s[0])
		);
		UI_TriggerSmoother UIs_MusicKeys1 (
			.clock_50Mhz(max10Board_50MhzClock),
			.inputWire(max10Board_GPIO_Input_MusicKeys[1]),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_MusicKeys_s[1])
		);
		UI_TriggerSmoother UIs_MusicKeys2 (
			.clock_50Mhz(max10Board_50MhzClock),
			.inputWire(max10Board_GPIO_Input_MusicKeys[2]),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_MusicKeys_s[2])
		);
		UI_TriggerSmoother UIs_MusicKeys3 (
			.clock_50Mhz(max10Board_50MhzClock),
			.inputWire(max10Board_GPIO_Input_MusicKeys[3]),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_MusicKeys_s[3])
		);
		UI_TriggerSmoother UIs_MusicKeys4 (
			.clock_50Mhz(max10Board_50MhzClock),
			.inputWire(max10Board_GPIO_Input_MusicKeys[4]),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_MusicKeys_s[4])
		);
		UI_TriggerSmoother UIs_MusicKeys5 (
			.clock_50Mhz(max10Board_50MhzClock),
			.inputWire(max10Board_GPIO_Input_MusicKeys[5]),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_MusicKeys_s[5])
		);
	wire max10Board_GPIO_Input_PlaySong1_s;
		UI_TriggerSmoother UIs_PlaySong1 (
			.clock_50Mhz(max10Board_50MhzClock),
			.inputWire(max10Board_GPIO_Input_PlaySong1),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_PlaySong1_s)
		);
	wire max10Board_GPIO_Input_PlaySong0_s;
		UI_TriggerSmoother UIs_PlaySong0 (
			.clock_50Mhz(max10Board_50MhzClock),
			.inputWire(max10Board_GPIO_Input_PlaySong0),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_PlaySong0_s)
		);
	wire max10Board_GPIO_Input_MakeRecording_s;
		UI_TriggerSmoother UIs_Makerecording (
			.clock_50Mhz(max10Board_50MhzClock),
			.inputWire(max10Board_GPIO_Input_MakeRecording),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_MakeRecording_s)
		);
	wire max10Board_GPIO_Input_PlayRecording_s;
		UI_TriggerSmoother UIs_PlayRecording (
			.clock_50Mhz(max10Board_50MhzClock),
			.inputWire(max10Board_GPIO_Input_PlayRecording),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_PlayRecording_s)
		);

	
	
	
	
	
	
	//----------------------------
	//-- Music Keys
	//-----These operate only in the state DoNothing and MakeRecording.  
	wire [5:0] musicKeysDebugTemp ; //Stores output.  Basically input keys if in current state.
	MusicKeysController musicKeysController (
		.clock_50Mhz(max10Board_50MhzClock),
		.reset_n(systemReset_n),
		.currentState(outputCurrentState), //This is controlled by MusicBoxStateController.   
		.input_MusicKey(max10Board_GPIO_Input_MusicKeys_s),
		// .debugString, //This is used to send any data out of the module for testing purposes.  Follows no format.
		.outputKeyPressed(musicKeysDebugTemp)
	);
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	//--CURRENT DEBUG SETUP.
		//State is displayed on first LEDs, music keys on the later half.
	//assign max10Board_LED[9] = CLK_1Hz;
	//assign max10Board_LED[8] = CLK_1Khz;
	//assign max10Board_LED[9:5] = output_DebugString[4:0];
	assign max10Board_LED[9:4] = musicKeysDebugTemp;
	//assign max10Board_LED[0] = (outputCurrentState == 1);
	assign max10Board_LED[1] = (outputCurrentState == 2);
	assign max10Board_LED[2] = (outputCurrentState == 3);
	assign max10Board_LED[3] = (outputCurrentState == 4);

	MusicBoxStateController musicBoxStateController (
		//==INPUT
		.clock_50Mhz(max10Board_50MhzClock),
		.clock_1Khz(CLK_1Khz),
		.reset_n(systemReset_n),
		
		//--UI
		.input_PlaySong0_n(max10Board_GPIO_Input_PlaySong0_s),
		.input_PlaySong1_n(max10Board_GPIO_Input_PlaySong1_s),
		.input_MakeRecording_n(max10Board_GPIO_Input_MakeRecording_s),
		.input_PlayRecording_n(max10Board_GPIO_Input_PlayRecording_s),
		.input_MusicKey(max10Board_GPIO_Input_MusicKeys_s),

		//==OUTPUT
		.debugString(output_DebugString), //This is used to send any data out of the module for testing purposes.  Follows no format.
		.outputState(outputCurrentState) //
	
	);
	

	//----------------------------
	//-- SPI Output---------------
	//----------------------------
	//Will always have a set of X bits and a signal to send.
	//The system will take those bits and send them bit by bit in the neccesary way.
	//The system will have a 'IsBusy' flag, and a 'SendComplete' flag.  
	reg [11:0] SPI_Output_WriteSample;
	
	
	always_ff @ (posedge CLK_100hz, negedge systemReset_n) begin
		if (systemReset_n == 0) begin
			SPI_Output_WriteSample <= 0;
		end
		else if (SPI_Output_WriteSample == 4000) begin
			SPI_Output_WriteSample <= 0;
		end
		else begin
			SPI_Output_WriteSample <= SPI_Output_WriteSample + 1;
		end
	
	end 
	wire 		SPI_Output_SendSample;
	assign SPI_Output_SendSample = 0;
	//assign SPI_Output_WriteSample = (max10Board_GPIO_Input_PlaySong1_s == 1) ? 12'b1111_1111_1111 : 12'b000_0000_1111;// + 12'b0000_0010_0000;
	 
	//assign SPI_Output_SendSample = 0;//max10Board_GPIO_Input_PlaySong1_s;
	wire 		SPI_Output_isBusy;
	assign max10Board_LED[0] =SPI_Output_isBusy;
	wire 		SPI_Output_transmitComplete;
	
	//	output wire max10Board_GPIO_Output_SPI_SCLK; //Data clock per bit
	//output wire max10Board_GPIO_Output_SPI_SYNC_n; //Low when sending data
	//output wire max10Board_GPIO_Output_SPI_DIN; //Data bits
	
	// always_ff @ (negedge max10Board_GPIO_Input_PlaySong0_s, posedge SPI_Output_isBusy) begin
		// if (SPI_Output_isBusy == 1) begin
			// SPI_Output_SendSample <= 1;
		// end
		// else begin
			// SPI_Output_SendSample <= 0;
		// end
	// end
	
	SPI_OutputControllerDac sPI_OutputControllerDac (
		.clock_50Mhz(max10Board_50MhzClock),
		.clock_1Khz(CLK_1Khz),
		.reset_n(systemReset_n),
		
		.output_SPI_SCLK(max10Board_GPIO_Output_SPI_SCLK),
		.output_SPI_SYNC_n(max10Board_GPIO_Output_SPI_SYNC_n),
		.output_SPI_DIN(max10Board_GPIO_Output_SPI_DIN),
		
		.inputSample(SPI_Output_WriteSample), //12 bits that will be sent to the DAC
		.sendSample_n(SPI_Output_SendSample), //Active low signal.  If the system is not busy, it will begin sending the sample out.
		
		.isBusy(SPI_Output_isBusy),
		.transmitComplete(SPI_Output_transmitComplete) //Goes high for 71Khz when this completes the signal
	);

	
	
endmodule