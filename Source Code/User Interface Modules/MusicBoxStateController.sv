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
		input logic clock_1Khz,
		//--Controlled by switch
		input logic reset_n,
		
		//--GPIO input.  These pins are connected to debouncing modules.
		input logic input_PlaySong0_n,
		input logic input_PlaySong1_n,
		input logic input_MakeRecording_n,
		input logic input_PlayRecording_n,
		input logic [5:0] input_MusicKey,
		
		//--This is used to send any data out of the module for testing purposes.  Follows no format.
		output logic [31:0] debugString,  
		
		//--Current state the state machine is in.
		output logic [4:0] outputState 
		);
		
		//This is a clocked state machine for sake of simplicity.  
		assign outputState = currentState;
		enum { state_DoNothing, state_PlaySong0, state_PlaySong1, state_PlayRecording, state_MakeRecording } currentState;
		
		always_ff @(posedge clock_50Mhz, negedge reset_n) begin
			if (reset_n == 1'b0) begin
				 currentState = state_DoNothing; //Force to 0, the 'Do Nothing' State
			end
			else begin
				//----DO NOTHING STATE
				if (currentState == state_DoNothing) begin
					//If user is pressing Song0 button
					if (input_PlaySong0_n == 0) begin
						currentState <= state_PlaySong0;
					end
					
					//If user is pressing Song1 button
					if (input_PlaySong1_n == 0) begin
						currentState <= state_PlaySong1;
					end
					
					//If user is pressing PLAY recording button
					if (input_PlayRecording_n == 0) begin
						currentState <= state_PlayRecording;
					end
					
					//If user is pressing MAKE recording button
					if (input_MakeRecording_n == 0) begin
						currentState <= state_MakeRecording;
					end
					
					
				end
				
				//---PLAY SONG 0 STATE
				else if (currentState == state_PlaySong0) begin
					if (playSong0_StateComplete == 1) begin
						currentState <= state_DoNothing;
					end
				end
				
				//----PLAY SONG 1 STATE
				else if (currentState == state_PlaySong1) begin
					if (playSong1_StateComplete == 1) begin
						currentState <= state_DoNothing;
					end
				end
				
				//----PLAY RECORDING STATE
				else if (currentState == state_PlayRecording) begin
					if (playRecording_StateComplete == 1) begin
						currentState <= state_DoNothing;
					end
				end
				
				//----MAKE RECORDING STATE
				else if (currentState == state_MakeRecording) begin
					if (makeRecording_StateComplete == 1) begin
						currentState <= state_DoNothing;
					end
				end

			
			
			end
		end
		
		
		//--Initialize the individual state controllers.
		//These only run when the current state input matches their own. 
		reg playSong0_StateComplete;
		MusicBoxState_PlaySong0 musicBoxState_PlaySong0 (
			.clock_50Mhz(clock_50Mhz),
			.clock_1Khz(clock_1Khz),
			.reset_n(reset_n),
			.currentState(currentState),
			.debugString(debugString),
			.stateComplete(playSong0_StateComplete)
		);
		
		reg playSong1_StateComplete;
		MusicBoxState_PlaySong1 musicBoxState_PlaySong1 (
			.clock_50Mhz(clock_50Mhz),
			.clock_1Khz(clock_1Khz),
			.reset_n(reset_n),
			.currentState(currentState),
			.debugString(debugString),
			.stateComplete(playSong1_StateComplete)
		);
		
		reg makeRecording_StateComplete;
		MusicBoxState_MakeRecording musicBoxState_MakeRecording (
			.clock_50Mhz(clock_50Mhz),
			.clock_1Khz(clock_1Khz),
			.reset_n(reset_n),
			.currentState(currentState),
			.debugString(debugString),
			.stateComplete(makeRecording_StateComplete)
		);
		
		reg playRecording_StateComplete;
		MusicBoxState_PlayRecording MusicBoxState_PlayRecording (
			.clock_50Mhz(clock_50Mhz),
			.clock_1Khz(clock_1Khz),
			.reset_n(reset_n),
			.currentState(currentState),
			.debugString(debugString),
			.stateComplete(playRecording_StateComplete)
		);

	// ClockGenerator clockGenerator_1hz (
		// .inputClock(CLK_1kHz),
		// .reset_n(systemReset_n),
		// .outputClock(CLK_1Hz)
	// );

endmodule