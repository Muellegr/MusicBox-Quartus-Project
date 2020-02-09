module MusicBoxState_PlayRecording( 
		input logic clock_50Mhz,
		input logic clock_1Khz,
		input logic reset_n,
		input logic [4:0] currentState, //This is controlled by MusicBoxStateController.   
		
		output logic [31:0] debugString, //This is used to send any data out of the module for testing purposes.  Follows no format.
		
		//Set to 1 when this stage is complete and is ready to return to DoNothing.
		output logic stateComplete
		);
		
		//This will count to 5000 on the 1Khz cock.    15bits can count to 32768.
		reg [ 15: 0] counter ;
		assign debugString = {16'b0, counter};
	
		always_ff @(posedge clock_1Khz ) begin //clock_1Khz negedge reset_n 
			//If current state isn't equal to 1. 
				//Does not like resetting here.  I think because reset influences currentState.
			if (currentState != 1'b1) begin
				counter <= 16'b0;
				stateComplete <= 1'b0;
			end
			else begin
				//If counter is sitting at the required amount of clock edges (about 5 seconds worth)
				if (counter == 16'd5000) begin
					stateComplete <= 1'b1;
					counter <= 16'd0;
				end
				//Otherwhys simply increment
				else begin
					stateComplete <= 1'b0;
					counter <= counter + 16'd1;
				end
			end
		
		end
				
endmodule