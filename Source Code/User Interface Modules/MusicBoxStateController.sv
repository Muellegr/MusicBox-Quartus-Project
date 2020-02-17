/*
Acts as main hub for control signals.


00 - 0000 - Do Nothing
01 - 0001 - Play Song 0
02 - 0010 - Play Song 1
03 - 0011 - Play Recording
04 - 0100 - Make Recording
05 - 0101 - 
06 - 0110 - 
07 - 0111 - 
08 - 1000 - ERROR : Debug State. State is held here.  This is currently only state with 4th bit high.
09 - 1001 - 
10 - 1010 - 
11 - 1011 - 
12 - 1100 - 
13 - 1101 - 
14 - 1110 - 
15 - 1111 - 

*/


module MusicBoxStateController ( 
		//--FPGA generated clock
		input logic clock_50Mhz,
		//--Module generated clock based off 50Mhz
		input logic clock_22Khz,
		input logic clock_1Khz,
		input logic clock_1hz,
		//--Controlled by switch
		input logic reset_n,
		
		//--GPIO input.  These pins are connected to debouncing modules.
		input logic input_PlaySong0_n,
		input logic input_PlaySong1_n,
		input logic input_MakeRecording_n,
		input logic input_PlayRecording_n,
		input logic [5:0] input_MusicKey, //Unused
		//
		//--This is used to send any data out of the module for testing purposes.  Follows no format.
		output logic [31:0] debugString,  
		
		//--Current state the state machine is in.
		output logic [4:0] outputState,

		//--SDRAM Controls here

		output logic [24:0] sdram_inputAddress, 
		output logic [15:0] sdram_writeData, 
		input  logic [15:0] sdram_readData,
		output logic 		sdram_isWriting, //Will the command be a write (1) or read (0)
		output logic 		sdram_inputValid, //Active high, perform command

		input logic 		sdram_outputValid, //sdram_readData has data when this is high.
		input logic 		sdram_recievedCommand,
		input logic 		sdram_isBusy
		);
		enum bit [4:0] { state_DoNothing=5'd0, state_PlaySong0=5'd1, state_PlaySong1=5'd2, state_PlayRecording=5'd3, state_MakeRecording=5'd4, state_EndState=5'd5 } currentState;
		
		//This is a clocked state machine for sake of simplicity.  
		assign outputState = currentState;
			
		//------------------------------------------
		//--Initialize the individual state controllers.
		//		These only run when the current state input matches their own. 
		//		Automatically reset when the state does not match their own.
		reg playSong0_StateComplete;
		MusicBoxState_PlaySong0 musicBoxState_PlaySong0 (
			.clock_50Mhz(clock_50Mhz),
			.clock_1Khz(clock_1Khz),
			.reset_n(reset_n),
			.currentState(currentState),
			//.debugString(debugString),
			.stateComplete(playSong0_StateComplete)
		);
		
		reg playSong1_StateComplete;
		MusicBoxState_PlaySong1 musicBoxState_PlaySong1 (
			.clock_50Mhz(clock_50Mhz),
			.clock_1Khz(clock_1Khz),
			.reset_n(reset_n),
			.currentState(currentState),
			//.debugString(debugString),
			.stateComplete(playSong1_StateComplete)
		);
		//--SDRAM interface controller for states.  Only 1 state controls the SDRAM at a time.
		always @ * begin 
			case(currentState)
				state_MakeRecording :  begin
					 sdram_inputAddress = mr_sdram_inputAddress;
					 sdram_writeData = mr_sdram_writeData ;
					 sdram_isWriting = mr_sdram_isWriting;
					 sdram_inputValid = mr_sdram_inputValid;
				end 
				state_PlayRecording :  begin
					sdram_inputAddress = pr_sdram_inputAddress;
					sdram_writeData = pr_sdram_writeData ;
					sdram_isWriting = pr_sdram_isWriting;
					sdram_inputValid = pr_sdram_inputValid;
				end 

				default :begin 
					sdram_inputAddress = 25'd0;
					sdram_writeData = 16'd0;
					sdram_isWriting = 1'd0;
					sdram_inputValid = 1'd0;
				end 
			endcase 
		end

		// assign sdram_inputAddress = ( (currentState == state_MakeRecording) * mr_sdram_inputAddress) || ((currentState == state_PlayRecording) * pr_sdram_inputAddress);
		// assign sdram_writeData    = ( (currentState == state_MakeRecording) * mr_sdram_writeData)    || ((currentState == state_PlayRecording) * pr_sdram_writeData);
		
		// assign sdram_isWriting    = ( (currentState == state_MakeRecording) * mr_sdram_isWriting)    || ((currentState == state_PlayRecording) * pr_sdram_isWriting);
		// assign sdram_inputValid   = ( (currentState == state_MakeRecording) * mr_sdram_inputValid)   || ((currentState == state_PlayRecording) * pr_sdram_inputValid);
		//--


		reg makeRecording_StateComplete;
		reg [24:0] mr_sdram_inputAddress;
		reg [15:0] mr_sdram_writeData;
		reg mr_sdram_isWriting;
		reg mr_sdram_inputValid;
	
		MusicBoxState_MakeRecording musicBoxState_MakeRecording (
			.clock_50Mhz(clock_50Mhz),
			.clock_22Khz(clock_22Khz),
			.clock_1Khz(clock_1Khz),
			.clock_1hz(clock_1hz),
			.reset_n(reset_n),
			.mainState(currentState),
			//.debugString(debugString),
			.stateComplete(makeRecording_StateComplete),
			//--SDRAM interface
			.sdram_inputAddress(mr_sdram_inputAddress),
			.sdram_writeData(mr_sdram_writeData),
			.sdram_readData(sdram_readData),
			.sdram_isWriting(mr_sdram_isWriting),
			.sdram_inputValid(mr_sdram_inputValid),
			//--
			.sdram_outputValid(sdram_outputValid),
			.sdram_recievedCommand(sdram_recievedCommand),
			.sdram_isBusy(sdram_isBusy)
		);
		/*
	output logic [24:0] sdram_inputAddress, 
		output logic [15:0] sdram_writeData, 
		input  logic [15:0] sdram_readData,
		output logic 		sdram_isWriting, //Will the command be a write (1) or read (0)
		output logic 		sdram_inputValid, //Active high, perform command

		input logic 		sdram_outputValid, //sdram_readData has data when this is high.
		input logic 		sdram_recievedCommand,
		input logic 		sdram_isBusy
		*/
		
		reg playRecording_StateComplete;
		reg [24:0] pr_sdram_inputAddress;
		reg [15:0] pr_sdram_writeData;
		reg pr_sdram_isWriting;
		reg pr_sdram_inputValid;
		MusicBoxState_PlayRecording MusicBoxState_PlayRecording (
			.clock_50Mhz(clock_50Mhz),
			.clock_22Khz(clock_22Khz),
			.clock_1Khz(clock_1Khz),
			.clock_1hz(clock_1hz),
			.reset_n(reset_n),
			.mainState(currentState),
			.debugString(debugString),
			.stateComplete(playRecording_StateComplete),
			//--SDRAM interface
			.sdram_inputAddress(pr_sdram_inputAddress),
			.sdram_writeData(pr_sdram_writeData),
			.sdram_readData(sdram_readData),
			.sdram_isWriting(pr_sdram_isWriting),
			.sdram_inputValid(pr_sdram_inputValid),
			//--
			.sdram_outputValid(sdram_outputValid),
			.sdram_recievedCommand(sdram_recievedCommand),
			.sdram_isBusy(sdram_isBusy)
		);
		
		//------------------------------------------
		//--State machine controller.  Looks at User Interface signals.
		always_ff @(posedge clock_50Mhz, negedge reset_n) begin
			if (reset_n == 1'b0) begin
				 currentState <= state_DoNothing; //Force to 0, the 'Do Nothing' State
			end
			else begin
				//----DO NOTHING STATE
				//--If user is holding button down, it will activate the correct state. 
				if (currentState == state_DoNothing) begin
					//If user is pressing Song0 button
					if (input_PlaySong0_n == 1'b0) begin
						currentState <= state_PlaySong0;
					end
					
					//If user is pressing Song1 button
					if (input_PlaySong1_n == 1'b0) begin
						currentState <= state_PlaySong1;
					end
					
					//If user is pressing PLAY recording button
					if (input_PlayRecording_n == 1'b0) begin
						currentState <= state_PlayRecording;
					end
					
					//If user is pressing MAKE recording button
					if (input_MakeRecording_n == 1'b0) begin
						currentState <= state_MakeRecording;
					end
				end
				
				//---PLAY SONG 0 STATE
				else if (currentState == state_PlaySong0) begin
					if (playSong0_StateComplete == 1'b1) begin
						currentState <= state_EndState;
					end
				end
				
				//----PLAY SONG 1 STATE
				else if (currentState == state_PlaySong1) begin
					if (playSong1_StateComplete == 1'b1) begin
						currentState <= state_EndState;
					end
				end
				
				//----PLAY RECORDING STATE
				else if (currentState == state_PlayRecording) begin
					if (playRecording_StateComplete == 1'b1) begin
						currentState <= state_EndState;
					end
				end
				
				//----MAKE RECORDING STATE
				else if (currentState == state_MakeRecording) begin
					if (makeRecording_StateComplete == 1'b1) begin
						currentState <= state_EndState;
					end
				end
				//----Free up state, removes weird bug.
				else if (currentState == state_EndState) begin
					currentState <= state_DoNothing;
				end

			end
		end

endmodule