module MusicBoxState_PlayRecording( 
		input logic clock_50Mhz,
		input logic clock_1Khz,
		input logic clock_22Khz,
		input logic clock_1hz,
		input logic reset_n,
		input logic [4:0] mainState, //This is controlled by MusicBoxStateController.   
		
		output logic [31:0] debugString, //This is used to send any data out of the module for testing purposes.  Follows no format.
		output logic [15:0] pr_audioOutput, //current output data
		output logic 		outputActive, //Do we want to send information out?
		//Set to 1 when this stage is complete and is ready to return to DoNothing.
		output logic stateComplete,
		//output logic [15:0] pr_audioOutput,
		//--SDRAM interface
		output logic [24:0] sdram_inputAddress, 
		output logic [15:0] sdram_writeData, 
		input  logic [15:0] sdram_readData,
		output logic 		sdram_isWriting, //Will the command be a write (1) or read (0)
		output logic 		sdram_inputValid, //Active high, perform command

		input logic 		sdram_outputValid, //sdram_readData has data when this is high.
		input logic 		sdram_recievedCommand,
		input logic 		sdram_isBusy
		);
		
		//readData is data meant to go to the dac.  Only active when we are reading from the speaker.
		assign pr_audioOutput = readData;
		assign outputActive = (currentState == 5'd1);
		assign debugString = readData;

		//This will count to 5000 on the 1Khz cock.    15bits can count to 32768.
		reg [ 15: 0] counter ;
		//assign debugString = {16'b0, counter};
	
		reg [5 : 0] currentState ;


	always_ff @(posedge clock_1Khz ) begin //clock_1Khz negedge reset_n 
		//If current state isn't equal to 1. 
			//Does not like resetting here.  I think because reset influences mainState.
		if (mainState != 5'd3) begin
			counter <= 16'b0;
			stateComplete <= 1'b0;
			currentState  <= 0;
			//readData <= 0;
			
		end
		//If not current state
		else begin

			case(currentState)
				5'd0 :  begin
							//--Initial entry state. 
							currentState <= 6'd1;
						end
				//Playback state.  SDRAM is read, DAC uses signals.
				5'd1 :  begin
							if (stateComplete_1 == 2'd1) begin
								currentState <= 6'd12;
							end
							if (stateComplete_1 == 2'd2) begin 
								currentState <= 6'd13;
							end
						end
				5'd12 :  begin
							stateComplete <= 1'b1;
						end
				5'd13 :  begin
							;//stateComplete <= 1'b1;
						end
				default :begin
							currentState <= 6'd12;
						end  
			endcase

		end
	
	end

	//This updates 22050Hz a second.  This samples from some nice frequency generator place.  
	reg [18:0] addressCounter; //(22050 * 20 = 441000.  We need 441000 memory spaces to store the full 20 second song. Each memory address (16 bits) will only store 8bits.
	reg [1:0] stateComplete_1; //0 in progress, 1 success, 2 fail.   Failure mode is currently unused.

	//--Retireve data from SDRAM only when the 'outputValid' signal has been high.
		//Oddity : outputValid is active high, but doing this on rising edge does not retrieve the right data.
	reg [15:0] readData;
	always_ff @(negedge sdram_outputValid) begin
		if (mainState != 5'd3 || currentState != 5'd1) begin
			readData <= 16'd0;   //Don't reset this quite yet I think.  Might cause a weird static pop as it goes from extreme to nothing.
		end
		else begin
			readData <= sdram_readData; //This stores what output was over multiple clock cycles. 
		end
	end

	//
	always_ff @(posedge clock_22Khz ) begin //clock_1Khz negedge reset_n 
		//RESET
		if (mainState != 5'd3 || currentState != 5'd1) begin
			sdram_inputAddress <= 25'd0;
			sdram_writeData <= 16'd0;
			sdram_isWriting <= 1'd0;
			sdram_inputValid <= 1'd0;
			addressCounter <= 0;
			stateComplete_1 <= 2'b0;
		end
		//--Active playback mode
		else begin
			//Have we waited enough
			if (addressCounter == 22050 * 10) begin
				stateComplete_1 <= 1;
			end
			//Continue to retrieve samples
			else begin
				//--We are reading, not writing
				sdram_isWriting <= 1'b0;
				//--Current address
				sdram_inputAddress <= addressCounter;
				//--Begin writing to SDRAM
				sdram_inputValid <= 1'b1;
				//--Increment
				addressCounter <= addressCounter + 1;
			end //else 
		end //else 
	end	

endmodule