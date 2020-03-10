/*
PlaySong0 includes issues related to all modules.
20200126 : When counter reaches end, counter is set to 0.  This prevents a weird hangup issue when the button is held down.
	The wire stateComplete is checked at 50Mhz.  It is impossible for htis clock to miss this.


Song 0 will have a premade song in this.
When the song begins, a counter activates.
This counter determines which index we're at.
Index pulls up frequency and amplitude.

These will sum the values in here and send it to the DAC.
	The DAC will take this value when the state is equal to this and we have a special flag (needed?)
	Not needed since this has a singular purpose in lif.e

When it reaches the end OR detects user input after a second (index position) then it exits this state.
	this forces speaker quiet.


	Frequencies : 14 bits : Up to 128 unique frequencies.
	Playback : 2^7 bits.  This gives 128 unique frequencies to select from




	Generator script
	
	Look through song.
		Find top 128 frequencies. 
			not top 128.  
		Collect all important frequencies
		sort
		combine until 128?


		or 2^13 bits
			Each frequency stored

		For simplicity, we will store acutal frequency in 12 bits (up to 4000Hz)
		Amplitude : 8 bits

		200* (12 + 8) = 40000 bits per


Want song module.
	Contains large array of songs.  
	
	Lists frequency to play and amplitude value of part

	Do it inhouse.

	For now, include signal generators in the song itself.

	Initalize test reg


	Setup counters that give correct index

	Write basic arrays that the index pulls from.  Gets amplitude and frequency.

	Feed amplitude, frequency into frequency generators


*/
//const reg  songStepSize = 10'd10; //Time in ms between song update
//const  reg songIndexCount = 10'd100; //Number of array indexes to reach before this is complete

module MusicBoxState_PlaySong0 ( 
		input logic clock_50Mhz,
		input logic clock_32Khz,
		input logic clock_1Khz,

		input logic reset_n,
		input logic [4:0] currentState, //This is controlled by MusicBoxStateController.   
		
		output logic [31:0] debugString, //This is used to send any data out of the module for testing purposes.  Follows no format.
		
		//Set to 1 when this stage is complete and is ready to return to DoNothing.
		output logic stateComplete,

		//This is the final output meant to be sent to the DAC.
		output logic [7:0] audioAmplitudeOutput,

		output logic [31:0] ROM_Song0Index, //Points to byte, not rom address itself.
		output logic [31:0] ROM_Song0Index_Max,
		input logic [7:0] ROM_Song0Data
		);
		//assign debugString = {16'b0, milisecondCounter};
		//reg [ 15: 0] counter ;

		//Match with songIndexCount
		assign ROM_Song0Index_Max = 1000;

		reg [9:0] songIndexCounter ; //Current index value of the song.  This should always be clamped between 0 and songIndexCount.
		reg [9:0] milisecondCounter ; //Counts miliseconds.  Reset when reach songStepSize.

		reg outputActive;
		// always_ff @(posedge clock_1Khz ) begin //clock_1Khz negedge reset_n 
		// 	if (currentState != 5'd1) begin
		// 		//counter <= 16'b0;
		// 		stateComplete <= 1'b0;
		// 		songIndexCounter <= 10'd0; 
		// 		milisecondCounter <= 10'd0;
		// 		outputActive <= 0;
		// 	end
		// 	else begin
		// 		outputActive <= 1;
		// 		if (songIndexCounter == 635 -1) begin
		// 			stateComplete <= 1'b1; 

		// 		end
		// 		//If we have not reached end of song
		// 		else begin
		// 			if ( milisecondCounter == 10'd50) begin
		// 				milisecondCounter <= 0; //Set back to 0
		// 				songIndexCounter <= songIndexCounter + 1;
		// 			end
		// 			else begin
		// 				milisecondCounter <= milisecondCounter + 1;
		// 			end
		// 		end

		// 	end //If correct state
		
		// end //Clock


		wire CLK_16Khz ;
	ClockGenerator clockGenerator_16Khz (
		.inputClock(max10Board_50MhzClock),
		.reset_n(systemReset_n),
		.outputClock(CLK_16Khz)
	);
		defparam	clockGenerator_16Khz.BitsNeeded = 16; //Must be able to count up to InputClockEdgesToCount.  
		defparam	clockGenerator_16Khz.InputClockEdgesToCount = 1562; 


	always_ff @ (posedge CLK_16Khz) begin
		if (currentState != 5'd1) begin
			ROM_Song0Index <= 0;
			stateComplete <= 1'b0;
			//songIndexCounter <= 10'd0; 
			//milisecondCounter <= 10'd0;
			outputActive <= 0;
		end
		else begin
			outputActive <= 1;
			if (ROM_Song0Index == ROM_Song0Index_Max) begin
				stateComplete <= 1'b1; 
				ROM_Song0Index <= 0;

			end
			else begin
				ROM_Song0Index <= ROM_Song0Index + 1;
			end

		end
	end


endmodule