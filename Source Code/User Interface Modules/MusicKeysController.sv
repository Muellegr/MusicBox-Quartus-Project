module MusicKeysController ( 
		input logic clock_50Mhz,
		input logic reset_n,
		input logic [4:0] currentState, //This is controlled by MusicBoxStateController.   
		input logic [5:0] input_MusicKey,
		
		output logic [31:0] debugString, //This is used to send any data out of the module for testing purposes.  Follows no format.
		
		//Output logic for sending signals to the frequency generator here.  
		output logic [5:0] outputKeyPressed
		);

		
		//If the music key is held down  AND   current state is doing nothing(0) or playing recording(4)
		assign outputKeyPressed[0] = (input_MusicKey[0] == 1'b0 && (currentState == 5'd0 || currentState == 5'd4)) * 1'b1;
		assign outputKeyPressed[1] = (input_MusicKey[1] == 1'b0 && (currentState == 5'd0 || currentState == 5'd4)) * 1'b1;
		assign outputKeyPressed[2] = (input_MusicKey[2] == 1'b0 && (currentState == 5'd0 || currentState == 5'd4)) * 1'b1;
		assign outputKeyPressed[3] = (input_MusicKey[3] == 1'b0 && (currentState == 5'd0 || currentState == 5'd4)) * 1'b1;
		assign outputKeyPressed[4] = (input_MusicKey[4] == 1'b0 && (currentState == 5'd0 || currentState == 5'd4)) * 1'b1;
		assign outputKeyPressed[5] = (input_MusicKey[5] == 1'b0 && (currentState == 5'd0 || currentState == 5'd4)) * 1'b1;
		
endmodule