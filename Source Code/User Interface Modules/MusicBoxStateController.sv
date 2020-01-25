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
		input logic clock_50Mhz,
		input logic reset_n,
		input logic input_PlaySong0_n,
		input logic input_PlaySong1_n,
		input logic input_MakeRecording_n,
		input logic input_PlayRecording_n,
		input logic [5:0] input_MusicKey,
		
		output logic [31:0] debugString, //This is used to send any data out of the module for testing purposes.  Follows no format.
		output logic [4:0] outputState //
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
				
				end
				
				//----PLAY SONG 1 STATE
				else if (currentState == state_PlaySong1) begin
				
				end
				
				//----PLAY RECORDING STATE
				else if (currentState == state_PlayRecording) begin
				
				end
				
				//----MAKE RECORDING STATE
				else if (currentState == state_MakeRecording) begin
				
				end

			
			
			end
		end
endmodule