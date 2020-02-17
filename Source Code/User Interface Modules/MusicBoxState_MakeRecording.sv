module MusicBoxState_MakeRecording ( 
	input logic clock_50Mhz,
	input logic clock_22Khz,
	input logic clock_1Khz,
	input logic clock_1hz,
	input logic reset_n,
	input logic [4:0] mainState, //This is controlled by MusicBoxStateController.   
	
	output logic [31:0] debugString, //This is used to send any data out of the module for testing purposes.  Follows no format.
	//
	//Set to 1 when this stage is complete and is ready to return to DoNothing.
	output logic stateComplete,

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
	
	//This will count to 5000 on the 1Khz cock.    15bits can count to 32768.
	reg [ 15: 0] counter ;
	assign debugString = {16'b0, counter};
/*
Add in state machine.

Do nothing state
10 empty states
11 : Do nothing, count to a value.
12 : Memory is active.  stores a bunch of stuff at 1 value.
13 : Stop recording
14 : End state

*/
	reg [5 : 0] currentState ;
	always_ff @(posedge clock_1Khz ) begin //clock_1Khz negedge reset_n 
		//If current state isn't equal to 1. 
			//Does not like resetting here.  I think because reset influences mainState.
		if (mainState != 5'd4) begin
			counter <= 16'b0;
			stateComplete <= 1'b0;
			currentState  <= 0;
			
		end
		//If not current state
		else begin

			case(currentState)
				5'd0 :  begin
							currentState <= 6'd11;
						end
				//In d11, state is active.  Count to 5s.  
				5'd11 :  begin
							if (stateComplete_11 == 1'b1) begin
								currentState <= 6'd12;
							end
						end
				5'd12 :  begin
							stateComplete <= 1'b1;
						end
				default :begin
							currentState <= 6'd12;
						end  
			endcase




			// //If counter is sitting at the required amount of clock edges (about 5 seconds worth)
			// if (counter == 16'd5000) begin
			// 	stateComplete <= 1'b1;
			// 	counter <= 16'd0;
			// end
			// //Otherwhys simply increment
			// else begin
			// 	stateComplete <= 1'b0;
			// 	counter <= counter + 16'd1;
			// end
		end
	
	end

	//This updates 22050Hz a second.  This samples from some nice frequency generator place.  
	reg [18:0] addressCounter; //(22050 * 20 = 441000.  We need 441000 memory spaces to store the full 20 second song. Each memory address (16 bits) will only store 8bits.
	reg stateComplete_11;
	always_ff @(posedge clock_22Khz ) begin //clock_1Khz negedge reset_n 
		//
		if (mainState != 5'd4 || currentState != 5'd11) begin
			sdram_inputAddress <= 25'd0;
			sdram_writeData <= 16'd0;
			sdram_isWriting <= 1'd0;
			sdram_inputValid <= 1'd0;
			addressCounter <= 0;
			stateComplete_11 <= 0;
		end
		else begin
			if (addressCounter == 22050 * 5) begin
				stateComplete_11 <= 1;
			end
			else begin
				//Begin writing data to SDRAM.
				//Because 'inputValid' is always 1, this is always rewriting the same address.  
				sdram_isWriting <= 1'b1;
				sdram_writeData <= 16'd128;
				sdram_inputAddress <= addressCounter;
				sdram_inputValid <= 1'b1;
				addressCounter <= addressCounter + 1;
			end
		end
	end	
endmodule