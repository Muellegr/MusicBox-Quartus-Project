module MusicBoxState_PlaySong0 ( 
		input logic clock_50Mhz,
		input logic reset_n,
		input logic [4:0] currentState, //This is controlled by MusicBoxStateController.   
		
		output logic [31:0] debugString, //This is used to send any data out of the module for testing purposes.  Follows no format.
		
		//Set to 1 when this stage is complete and is ready to return to DoNothing.
		output logic stateComplete
		);
		
		// always_ff @(posedge clock_50Mhz, negedge reset_n) begin
			// //If told to reset, or current state isn't equal to 1. 
			// if (reset_n == 0 || currentState != 1) begin
				
			// end
		
		// end
				
endmodule