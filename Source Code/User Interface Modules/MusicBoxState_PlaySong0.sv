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
const reg  songStepSize = 10'd10; //Time in ms between song update
const  reg songIndexCount = 10'd100; //Number of array indexes to reach before this is complete

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
		output logic [7:0] audioAmplitudeOutput

		);
		assign debugString = {16'b0, milisecondCounter};
		//reg [ 15: 0] counter ;

		//Match with songIndexCount
		

		reg [9:0] songIndexCounter ; //Current index value of the song.  This should always be clamped between 0 and songIndexCount.
		reg [9:0] milisecondCounter ; //Counts miliseconds.  Reset when reach songStepSize.

		reg outputActive;
		always_ff @(posedge clock_1Khz ) begin //clock_1Khz negedge reset_n 
			if (currentState != 5'd1) begin
				//counter <= 16'b0;
				stateComplete <= 1'b0;
				songIndexCounter <= 10'd0; 
				milisecondCounter <= 10'd0;
				outputActive <= 0;
			end
			else begin
				outputActive <= 1;
				if (songIndexCounter == 98 -1) begin
					stateComplete <= 1'b1; 

				end
				//If we have not reached end of song
				else begin
					if ( milisecondCounter == 10'd50) begin
						milisecondCounter <= 0; //Set back to 0
						songIndexCounter <= songIndexCounter + 1;
					end
					else begin
						milisecondCounter <= milisecondCounter + 1;
					end
				end

			end //If correct state
		
		end //Clock

	//--FREQUENCY GENERATORS
	assign audioAmplitudeOutput = (outputActive == 1'b1)? (SignalMultiply255(signalGeneratorOutput[0],currentAmplitude[0] )) + 
														  (SignalMultiply255(signalGeneratorOutput[1],currentAmplitude[1] )) + 
														  (SignalMultiply255(signalGeneratorOutput[2],currentAmplitude[2] ))
														 : 8'd0;
	SignalGenerator signalGenerator_Sine0(
		.CLK_32KHz(clock_32Khz),
		.reset_n( reset_n),
		.inputFrequency(currentFrequency[0]),
		.outputSample(signalGeneratorOutput[0])
	);
	SignalGenerator signalGenerator_Sine1(
		.CLK_32KHz(clock_32Khz),
		.reset_n( reset_n),
		.inputFrequency(currentFrequency[1]),
		.outputSample(signalGeneratorOutput[1])
	);
	SignalGenerator signalGenerator_Sine2(
		.CLK_32KHz(clock_32Khz),
		.reset_n( reset_n),
		.inputFrequency(currentFrequency[2]),
		.outputSample(signalGeneratorOutput[2])
	);

//-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-
//-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-
//-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=--=-=-=-=lol=-=-=--=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-
//-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-
//-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-
	wire [2:0][ 7:0] signalGeneratorOutput;
	wire [2:0][13:0] currentFrequency;
		assign currentFrequency[0] = songFrequencies[0][songIndexCounter];
		assign currentFrequency[1] = songFrequencies[1][songIndexCounter];
		assign currentFrequency[2] = songFrequencies[2][songIndexCounter];
	wire [2:0][ 7:0] currentAmplitude;
		assign currentAmplitude[0] = songFrequencyAmplitudes[0][songIndexCounter];
		assign currentAmplitude[1] = songFrequencyAmplitudes[1][songIndexCounter];
		assign currentAmplitude[2] = songFrequencyAmplitudes[2][songIndexCounter];

	function automatic  [7:0] SignalMultiply255 (input [7:0] a, input [7:0] b);
		return  ( (a * b + 127) * 1/255);
	endfunction		






	//COPY PASTE FROM FILE STARTING ON THIS LINE DOWNWARD. INCLUDE ENDMODULE
bit [2:0][98:0][13:0] songFrequencies;
bit [2:0][98:0][7:0] songFrequencyAmplitudes;

//-=-=-=-=-SONG DATA-=-=-=-=- 
   assign songFrequencies        [0][0] = 14'd500;
   assign songFrequencyAmplitudes[0][0] =  8'd89;
   assign songFrequencies        [1][0] = 14'd12800;
   assign songFrequencyAmplitudes[1][0] =  8'd0;
   assign songFrequencies        [2][0] = 14'd20400;
   assign songFrequencyAmplitudes[2][0] =  8'd0;
   //--
   assign songFrequencies        [0][1] = 14'd500;
   assign songFrequencyAmplitudes[0][1] =  8'd89;
   assign songFrequencies        [1][1] = 14'd12800;
   assign songFrequencyAmplitudes[1][1] =  8'd0;
   assign songFrequencies        [2][1] = 14'd20400;
   assign songFrequencyAmplitudes[2][1] =  8'd0;
   //--
   assign songFrequencies        [0][2] = 14'd500;
   assign songFrequencyAmplitudes[0][2] =  8'd89;
   assign songFrequencies        [1][2] = 14'd12800;
   assign songFrequencyAmplitudes[1][2] =  8'd0;
   assign songFrequencies        [2][2] = 14'd20400;
   assign songFrequencyAmplitudes[2][2] =  8'd0;
   //--
   assign songFrequencies        [0][3] = 14'd500;
   assign songFrequencyAmplitudes[0][3] =  8'd89;
   assign songFrequencies        [1][3] = 14'd12800;
   assign songFrequencyAmplitudes[1][3] =  8'd0;
   assign songFrequencies        [2][3] = 14'd20400;
   assign songFrequencyAmplitudes[2][3] =  8'd0;
   //--
   assign songFrequencies        [0][4] = 14'd500;
   assign songFrequencyAmplitudes[0][4] =  8'd89;
   assign songFrequencies        [1][4] = 14'd12800;
   assign songFrequencyAmplitudes[1][4] =  8'd0;
   assign songFrequencies        [2][4] = 14'd20400;
   assign songFrequencyAmplitudes[2][4] =  8'd0;
   //--
   assign songFrequencies        [0][5] = 14'd500;
   assign songFrequencyAmplitudes[0][5] =  8'd89;
   assign songFrequencies        [1][5] = 14'd12800;
   assign songFrequencyAmplitudes[1][5] =  8'd0;
   assign songFrequencies        [2][5] = 14'd20400;
   assign songFrequencyAmplitudes[2][5] =  8'd0;
   //--
   assign songFrequencies        [0][6] = 14'd500;
   assign songFrequencyAmplitudes[0][6] =  8'd89;
   assign songFrequencies        [1][6] = 14'd12800;
   assign songFrequencyAmplitudes[1][6] =  8'd0;
   assign songFrequencies        [2][6] = 14'd20400;
   assign songFrequencyAmplitudes[2][6] =  8'd0;
   //--
   assign songFrequencies        [0][7] = 14'd500;
   assign songFrequencyAmplitudes[0][7] =  8'd89;
   assign songFrequencies        [1][7] = 14'd12800;
   assign songFrequencyAmplitudes[1][7] =  8'd0;
   assign songFrequencies        [2][7] = 14'd20400;
   assign songFrequencyAmplitudes[2][7] =  8'd0;
   //--
   assign songFrequencies        [0][8] = 14'd500;
   assign songFrequencyAmplitudes[0][8] =  8'd89;
   assign songFrequencies        [1][8] = 14'd12800;
   assign songFrequencyAmplitudes[1][8] =  8'd0;
   assign songFrequencies        [2][8] = 14'd20400;
   assign songFrequencyAmplitudes[2][8] =  8'd0;
   //--
   assign songFrequencies        [0][9] = 14'd500;
   assign songFrequencyAmplitudes[0][9] =  8'd89;
   assign songFrequencies        [1][9] = 14'd12800;
   assign songFrequencyAmplitudes[1][9] =  8'd0;
   assign songFrequencies        [2][9] = 14'd20400;
   assign songFrequencyAmplitudes[2][9] =  8'd0;
   //--
   assign songFrequencies        [0][10] = 14'd500;
   assign songFrequencyAmplitudes[0][10] =  8'd89;
   assign songFrequencies        [1][10] = 14'd12800;
   assign songFrequencyAmplitudes[1][10] =  8'd0;
   assign songFrequencies        [2][10] = 14'd20400;
   assign songFrequencyAmplitudes[2][10] =  8'd0;
   //--
   assign songFrequencies        [0][11] = 14'd500;
   assign songFrequencyAmplitudes[0][11] =  8'd89;
   assign songFrequencies        [1][11] = 14'd12800;
   assign songFrequencyAmplitudes[1][11] =  8'd0;
   assign songFrequencies        [2][11] = 14'd20400;
   assign songFrequencyAmplitudes[2][11] =  8'd0;
   //--
   assign songFrequencies        [0][12] = 14'd500;
   assign songFrequencyAmplitudes[0][12] =  8'd89;
   assign songFrequencies        [1][12] = 14'd12800;
   assign songFrequencyAmplitudes[1][12] =  8'd0;
   assign songFrequencies        [2][12] = 14'd20400;
   assign songFrequencyAmplitudes[2][12] =  8'd0;
   //--
   assign songFrequencies        [0][13] = 14'd500;
   assign songFrequencyAmplitudes[0][13] =  8'd89;
   assign songFrequencies        [1][13] = 14'd12800;
   assign songFrequencyAmplitudes[1][13] =  8'd0;
   assign songFrequencies        [2][13] = 14'd20400;
   assign songFrequencyAmplitudes[2][13] =  8'd0;
   //--
   assign songFrequencies        [0][14] = 14'd500;
   assign songFrequencyAmplitudes[0][14] =  8'd89;
   assign songFrequencies        [1][14] = 14'd12800;
   assign songFrequencyAmplitudes[1][14] =  8'd0;
   assign songFrequencies        [2][14] = 14'd20400;
   assign songFrequencyAmplitudes[2][14] =  8'd0;
   //--
   assign songFrequencies        [0][15] = 14'd500;
   assign songFrequencyAmplitudes[0][15] =  8'd71;
   assign songFrequencies        [1][15] = 14'd493;
   assign songFrequencyAmplitudes[1][15] =  8'd16;
   assign songFrequencies        [2][15] = 14'd506;
   assign songFrequencyAmplitudes[2][15] =  8'd16;
   //--
   assign songFrequencies        [0][16] = 14'd500;
   assign songFrequencyAmplitudes[0][16] =  8'd42;
   assign songFrequencies        [1][16] = 14'd493;
   assign songFrequencyAmplitudes[1][16] =  8'd28;
   assign songFrequencies        [2][16] = 14'd506;
   assign songFrequencyAmplitudes[2][16] =  8'd28;
   //--
   assign songFrequencies        [0][17] = 14'd500;
   assign songFrequencyAmplitudes[0][17] =  8'd12;
   assign songFrequencies        [1][17] = 14'd493;
   assign songFrequencyAmplitudes[1][17] =  8'd12;
   assign songFrequencies        [2][17] = 14'd506;
   assign songFrequencyAmplitudes[2][17] =  8'd12;
   //--
   assign songFrequencies        [0][18] = 14'd0;
   assign songFrequencyAmplitudes[0][18] =  8'd0;
   assign songFrequencies        [1][18] = 14'd0;
   assign songFrequencyAmplitudes[1][18] =  8'd0;
   assign songFrequencies        [2][18] = 14'd0;
   assign songFrequencyAmplitudes[2][18] =  8'd0;
   //--
   assign songFrequencies        [0][19] = 14'd0;
   assign songFrequencyAmplitudes[0][19] =  8'd0;
   assign songFrequencies        [1][19] = 14'd0;
   assign songFrequencyAmplitudes[1][19] =  8'd0;
   assign songFrequencies        [2][19] = 14'd0;
   assign songFrequencyAmplitudes[2][19] =  8'd0;
   //--
   assign songFrequencies        [0][20] = 14'd0;
   assign songFrequencyAmplitudes[0][20] =  8'd0;
   assign songFrequencies        [1][20] = 14'd0;
   assign songFrequencyAmplitudes[1][20] =  8'd0;
   assign songFrequencies        [2][20] = 14'd0;
   assign songFrequencyAmplitudes[2][20] =  8'd0;
   //--
   assign songFrequencies        [0][21] = 14'd0;
   assign songFrequencyAmplitudes[0][21] =  8'd0;
   assign songFrequencies        [1][21] = 14'd0;
   assign songFrequencyAmplitudes[1][21] =  8'd0;
   assign songFrequencies        [2][21] = 14'd0;
   assign songFrequencyAmplitudes[2][21] =  8'd0;
   //--
   assign songFrequencies        [0][22] = 14'd0;
   assign songFrequencyAmplitudes[0][22] =  8'd0;
   assign songFrequencies        [1][22] = 14'd0;
   assign songFrequencyAmplitudes[1][22] =  8'd0;
   assign songFrequencies        [2][22] = 14'd0;
   assign songFrequencyAmplitudes[2][22] =  8'd0;
   //--
   assign songFrequencies        [0][23] = 14'd0;
   assign songFrequencyAmplitudes[0][23] =  8'd0;
   assign songFrequencies        [1][23] = 14'd0;
   assign songFrequencyAmplitudes[1][23] =  8'd0;
   assign songFrequencies        [2][23] = 14'd0;
   assign songFrequencyAmplitudes[2][23] =  8'd0;
   //--
   assign songFrequencies        [0][24] = 14'd500;
   assign songFrequencyAmplitudes[0][24] =  8'd24;
   assign songFrequencies        [1][24] = 14'd493;
   assign songFrequencyAmplitudes[1][24] =  8'd21;
   assign songFrequencies        [2][24] = 14'd506;
   assign songFrequencyAmplitudes[2][24] =  8'd21;
   //--
   assign songFrequencies        [0][25] = 14'd500;
   assign songFrequencyAmplitudes[0][25] =  8'd54;
   assign songFrequencies        [1][25] = 14'd493;
   assign songFrequencyAmplitudes[1][25] =  8'd26;
   assign songFrequencies        [2][25] = 14'd506;
   assign songFrequencyAmplitudes[2][25] =  8'd26;
   //--
   assign songFrequencies        [0][26] = 14'd500;
   assign songFrequencyAmplitudes[0][26] =  8'd84;
   assign songFrequencies        [1][26] = 14'd493;
   assign songFrequencyAmplitudes[1][26] =  8'd5;
   assign songFrequencies        [2][26] = 14'd506;
   assign songFrequencyAmplitudes[2][26] =  8'd5;
   //--
   assign songFrequencies        [0][27] = 14'd500;
   assign songFrequencyAmplitudes[0][27] =  8'd89;
   assign songFrequencies        [1][27] = 14'd12800;
   assign songFrequencyAmplitudes[1][27] =  8'd0;
   assign songFrequencies        [2][27] = 14'd20400;
   assign songFrequencyAmplitudes[2][27] =  8'd0;
   //--
   assign songFrequencies        [0][28] = 14'd500;
   assign songFrequencyAmplitudes[0][28] =  8'd89;
   assign songFrequencies        [1][28] = 14'd12800;
   assign songFrequencyAmplitudes[1][28] =  8'd0;
   assign songFrequencies        [2][28] = 14'd20400;
   assign songFrequencyAmplitudes[2][28] =  8'd0;
   //--
   assign songFrequencies        [0][29] = 14'd500;
   assign songFrequencyAmplitudes[0][29] =  8'd89;
   assign songFrequencies        [1][29] = 14'd12800;
   assign songFrequencyAmplitudes[1][29] =  8'd0;
   assign songFrequencies        [2][29] = 14'd20400;
   assign songFrequencyAmplitudes[2][29] =  8'd0;
   //--
   assign songFrequencies        [0][30] = 14'd500;
   assign songFrequencyAmplitudes[0][30] =  8'd89;
   assign songFrequencies        [1][30] = 14'd12800;
   assign songFrequencyAmplitudes[1][30] =  8'd0;
   assign songFrequencies        [2][30] = 14'd20400;
   assign songFrequencyAmplitudes[2][30] =  8'd0;
   //--
   assign songFrequencies        [0][31] = 14'd500;
   assign songFrequencyAmplitudes[0][31] =  8'd89;
   assign songFrequencies        [1][31] = 14'd12800;
   assign songFrequencyAmplitudes[1][31] =  8'd0;
   assign songFrequencies        [2][31] = 14'd20400;
   assign songFrequencyAmplitudes[2][31] =  8'd0;
   //--
   assign songFrequencies        [0][32] = 14'd500;
   assign songFrequencyAmplitudes[0][32] =  8'd89;
   assign songFrequencies        [1][32] = 14'd12800;
   assign songFrequencyAmplitudes[1][32] =  8'd0;
   assign songFrequencies        [2][32] = 14'd20400;
   assign songFrequencyAmplitudes[2][32] =  8'd0;
   //--
   assign songFrequencies        [0][33] = 14'd500;
   assign songFrequencyAmplitudes[0][33] =  8'd89;
   assign songFrequencies        [1][33] = 14'd12800;
   assign songFrequencyAmplitudes[1][33] =  8'd0;
   assign songFrequencies        [2][33] = 14'd20400;
   assign songFrequencyAmplitudes[2][33] =  8'd0;
   //--
   assign songFrequencies        [0][34] = 14'd500;
   assign songFrequencyAmplitudes[0][34] =  8'd89;
   assign songFrequencies        [1][34] = 14'd12800;
   assign songFrequencyAmplitudes[1][34] =  8'd0;
   assign songFrequencies        [2][34] = 14'd20400;
   assign songFrequencyAmplitudes[2][34] =  8'd0;
   //--
   assign songFrequencies        [0][35] = 14'd500;
   assign songFrequencyAmplitudes[0][35] =  8'd89;
   assign songFrequencies        [1][35] = 14'd12800;
   assign songFrequencyAmplitudes[1][35] =  8'd0;
   assign songFrequencies        [2][35] = 14'd20400;
   assign songFrequencyAmplitudes[2][35] =  8'd0;
   //--
   assign songFrequencies        [0][36] = 14'd500;
   assign songFrequencyAmplitudes[0][36] =  8'd89;
   assign songFrequencies        [1][36] = 14'd12800;
   assign songFrequencyAmplitudes[1][36] =  8'd0;
   assign songFrequencies        [2][36] = 14'd20400;
   assign songFrequencyAmplitudes[2][36] =  8'd0;
   //--
   assign songFrequencies        [0][37] = 14'd500;
   assign songFrequencyAmplitudes[0][37] =  8'd89;
   assign songFrequencies        [1][37] = 14'd12800;
   assign songFrequencyAmplitudes[1][37] =  8'd0;
   assign songFrequencies        [2][37] = 14'd20400;
   assign songFrequencyAmplitudes[2][37] =  8'd0;
   //--
   assign songFrequencies        [0][38] = 14'd500;
   assign songFrequencyAmplitudes[0][38] =  8'd89;
   assign songFrequencies        [1][38] = 14'd12800;
   assign songFrequencyAmplitudes[1][38] =  8'd0;
   assign songFrequencies        [2][38] = 14'd20400;
   assign songFrequencyAmplitudes[2][38] =  8'd0;
   //--
   assign songFrequencies        [0][39] = 14'd500;
   assign songFrequencyAmplitudes[0][39] =  8'd89;
   assign songFrequencies        [1][39] = 14'd12800;
   assign songFrequencyAmplitudes[1][39] =  8'd0;
   assign songFrequencies        [2][39] = 14'd20400;
   assign songFrequencyAmplitudes[2][39] =  8'd0;
   //--
   assign songFrequencies        [0][40] = 14'd500;
   assign songFrequencyAmplitudes[0][40] =  8'd89;
   assign songFrequencies        [1][40] = 14'd12800;
   assign songFrequencyAmplitudes[1][40] =  8'd0;
   assign songFrequencies        [2][40] = 14'd20400;
   assign songFrequencyAmplitudes[2][40] =  8'd0;
   //--
   assign songFrequencies        [0][41] = 14'd500;
   assign songFrequencyAmplitudes[0][41] =  8'd89;
   assign songFrequencies        [1][41] = 14'd12800;
   assign songFrequencyAmplitudes[1][41] =  8'd0;
   assign songFrequencies        [2][41] = 14'd20400;
   assign songFrequencyAmplitudes[2][41] =  8'd0;
   //--
   assign songFrequencies        [0][42] = 14'd500;
   assign songFrequencyAmplitudes[0][42] =  8'd89;
   assign songFrequencies        [1][42] = 14'd12800;
   assign songFrequencyAmplitudes[1][42] =  8'd0;
   assign songFrequencies        [2][42] = 14'd20400;
   assign songFrequencyAmplitudes[2][42] =  8'd0;
   //--
   assign songFrequencies        [0][43] = 14'd500;
   assign songFrequencyAmplitudes[0][43] =  8'd89;
   assign songFrequencies        [1][43] = 14'd12800;
   assign songFrequencyAmplitudes[1][43] =  8'd0;
   assign songFrequencies        [2][43] = 14'd20400;
   assign songFrequencyAmplitudes[2][43] =  8'd0;
   //--
   assign songFrequencies        [0][44] = 14'd500;
   assign songFrequencyAmplitudes[0][44] =  8'd89;
   assign songFrequencies        [1][44] = 14'd12800;
   assign songFrequencyAmplitudes[1][44] =  8'd0;
   assign songFrequencies        [2][44] = 14'd20400;
   assign songFrequencyAmplitudes[2][44] =  8'd0;
   //--
   assign songFrequencies        [0][45] = 14'd500;
   assign songFrequencyAmplitudes[0][45] =  8'd77;
   assign songFrequencies        [1][45] = 14'd493;
   assign songFrequencyAmplitudes[1][45] =  8'd11;
   assign songFrequencies        [2][45] = 14'd506;
   assign songFrequencyAmplitudes[2][45] =  8'd11;
   //--
   assign songFrequencies        [0][46] = 14'd500;
   assign songFrequencyAmplitudes[0][46] =  8'd47;
   assign songFrequencies        [1][46] = 14'd493;
   assign songFrequencyAmplitudes[1][46] =  8'd28;
   assign songFrequencies        [2][46] = 14'd506;
   assign songFrequencyAmplitudes[2][46] =  8'd28;
   //--
   assign songFrequencies        [0][47] = 14'd500;
   assign songFrequencyAmplitudes[0][47] =  8'd17;
   assign songFrequencies        [1][47] = 14'd493;
   assign songFrequencyAmplitudes[1][47] =  8'd16;
   assign songFrequencies        [2][47] = 14'd506;
   assign songFrequencyAmplitudes[2][47] =  8'd16;
   //--
   assign songFrequencies        [0][48] = 14'd0;
   assign songFrequencyAmplitudes[0][48] =  8'd0;
   assign songFrequencies        [1][48] = 14'd0;
   assign songFrequencyAmplitudes[1][48] =  8'd0;
   assign songFrequencies        [2][48] = 14'd0;
   assign songFrequencyAmplitudes[2][48] =  8'd0;
   //--
   assign songFrequencies        [0][49] = 14'd0;
   assign songFrequencyAmplitudes[0][49] =  8'd0;
   assign songFrequencies        [1][49] = 14'd0;
   assign songFrequencyAmplitudes[1][49] =  8'd0;
   assign songFrequencies        [2][49] = 14'd0;
   assign songFrequencyAmplitudes[2][49] =  8'd0;
   //--
   assign songFrequencies        [0][50] = 14'd0;
   assign songFrequencyAmplitudes[0][50] =  8'd0;
   assign songFrequencies        [1][50] = 14'd0;
   assign songFrequencyAmplitudes[1][50] =  8'd0;
   assign songFrequencies        [2][50] = 14'd0;
   assign songFrequencyAmplitudes[2][50] =  8'd0;
   //--
   assign songFrequencies        [0][51] = 14'd0;
   assign songFrequencyAmplitudes[0][51] =  8'd0;
   assign songFrequencies        [1][51] = 14'd0;
   assign songFrequencyAmplitudes[1][51] =  8'd0;
   assign songFrequencies        [2][51] = 14'd0;
   assign songFrequencyAmplitudes[2][51] =  8'd0;
   //--
   assign songFrequencies        [0][52] = 14'd0;
   assign songFrequencyAmplitudes[0][52] =  8'd0;
   assign songFrequencies        [1][52] = 14'd0;
   assign songFrequencyAmplitudes[1][52] =  8'd0;
   assign songFrequencies        [2][52] = 14'd0;
   assign songFrequencyAmplitudes[2][52] =  8'd0;
   //--
   assign songFrequencies        [0][53] = 14'd500;
   assign songFrequencyAmplitudes[0][53] =  8'd5;
   assign songFrequencies        [1][53] = 14'd493;
   assign songFrequencyAmplitudes[1][53] =  8'd5;
   assign songFrequencies        [2][53] = 14'd506;
   assign songFrequencyAmplitudes[2][53] =  8'd5;
   //--
   assign songFrequencies        [0][54] = 14'd500;
   assign songFrequencyAmplitudes[0][54] =  8'd35;
   assign songFrequencies        [1][54] = 14'd493;
   assign songFrequencyAmplitudes[1][54] =  8'd26;
   assign songFrequencies        [2][54] = 14'd506;
   assign songFrequencyAmplitudes[2][54] =  8'd26;
   //--
   assign songFrequencies        [0][55] = 14'd500;
   assign songFrequencyAmplitudes[0][55] =  8'd65;
   assign songFrequencies        [1][55] = 14'd493;
   assign songFrequencyAmplitudes[1][55] =  8'd21;
   assign songFrequencies        [2][55] = 14'd506;
   assign songFrequencyAmplitudes[2][55] =  8'd21;
   //--
   assign songFrequencies        [0][56] = 14'd500;
   assign songFrequencyAmplitudes[0][56] =  8'd89;
   assign songFrequencies        [1][56] = 14'd12800;
   assign songFrequencyAmplitudes[1][56] =  8'd0;
   assign songFrequencies        [2][56] = 14'd20400;
   assign songFrequencyAmplitudes[2][56] =  8'd0;
   //--
   assign songFrequencies        [0][57] = 14'd500;
   assign songFrequencyAmplitudes[0][57] =  8'd89;
   assign songFrequencies        [1][57] = 14'd12800;
   assign songFrequencyAmplitudes[1][57] =  8'd0;
   assign songFrequencies        [2][57] = 14'd20400;
   assign songFrequencyAmplitudes[2][57] =  8'd0;
   //--
   assign songFrequencies        [0][58] = 14'd500;
   assign songFrequencyAmplitudes[0][58] =  8'd89;
   assign songFrequencies        [1][58] = 14'd12800;
   assign songFrequencyAmplitudes[1][58] =  8'd0;
   assign songFrequencies        [2][58] = 14'd20400;
   assign songFrequencyAmplitudes[2][58] =  8'd0;
   //--
   assign songFrequencies        [0][59] = 14'd500;
   assign songFrequencyAmplitudes[0][59] =  8'd89;
   assign songFrequencies        [1][59] = 14'd12800;
   assign songFrequencyAmplitudes[1][59] =  8'd0;
   assign songFrequencies        [2][59] = 14'd20400;
   assign songFrequencyAmplitudes[2][59] =  8'd0;
   //--
   assign songFrequencies        [0][60] = 14'd500;
   assign songFrequencyAmplitudes[0][60] =  8'd89;
   assign songFrequencies        [1][60] = 14'd12800;
   assign songFrequencyAmplitudes[1][60] =  8'd0;
   assign songFrequencies        [2][60] = 14'd20400;
   assign songFrequencyAmplitudes[2][60] =  8'd0;
   //--
   assign songFrequencies        [0][61] = 14'd500;
   assign songFrequencyAmplitudes[0][61] =  8'd89;
   assign songFrequencies        [1][61] = 14'd12800;
   assign songFrequencyAmplitudes[1][61] =  8'd0;
   assign songFrequencies        [2][61] = 14'd20400;
   assign songFrequencyAmplitudes[2][61] =  8'd0;
   //--
   assign songFrequencies        [0][62] = 14'd500;
   assign songFrequencyAmplitudes[0][62] =  8'd89;
   assign songFrequencies        [1][62] = 14'd12800;
   assign songFrequencyAmplitudes[1][62] =  8'd0;
   assign songFrequencies        [2][62] = 14'd20400;
   assign songFrequencyAmplitudes[2][62] =  8'd0;
   //--
   assign songFrequencies        [0][63] = 14'd500;
   assign songFrequencyAmplitudes[0][63] =  8'd89;
   assign songFrequencies        [1][63] = 14'd12800;
   assign songFrequencyAmplitudes[1][63] =  8'd0;
   assign songFrequencies        [2][63] = 14'd20400;
   assign songFrequencyAmplitudes[2][63] =  8'd0;
   //--
   assign songFrequencies        [0][64] = 14'd500;
   assign songFrequencyAmplitudes[0][64] =  8'd89;
   assign songFrequencies        [1][64] = 14'd12800;
   assign songFrequencyAmplitudes[1][64] =  8'd0;
   assign songFrequencies        [2][64] = 14'd20400;
   assign songFrequencyAmplitudes[2][64] =  8'd0;
   //--
   assign songFrequencies        [0][65] = 14'd500;
   assign songFrequencyAmplitudes[0][65] =  8'd89;
   assign songFrequencies        [1][65] = 14'd12800;
   assign songFrequencyAmplitudes[1][65] =  8'd0;
   assign songFrequencies        [2][65] = 14'd20400;
   assign songFrequencyAmplitudes[2][65] =  8'd0;
   //--
   assign songFrequencies        [0][66] = 14'd500;
   assign songFrequencyAmplitudes[0][66] =  8'd89;
   assign songFrequencies        [1][66] = 14'd12800;
   assign songFrequencyAmplitudes[1][66] =  8'd0;
   assign songFrequencies        [2][66] = 14'd20400;
   assign songFrequencyAmplitudes[2][66] =  8'd0;
   //--
   assign songFrequencies        [0][67] = 14'd500;
   assign songFrequencyAmplitudes[0][67] =  8'd89;
   assign songFrequencies        [1][67] = 14'd12800;
   assign songFrequencyAmplitudes[1][67] =  8'd0;
   assign songFrequencies        [2][67] = 14'd20400;
   assign songFrequencyAmplitudes[2][67] =  8'd0;
   //--
   assign songFrequencies        [0][68] = 14'd500;
   assign songFrequencyAmplitudes[0][68] =  8'd89;
   assign songFrequencies        [1][68] = 14'd12800;
   assign songFrequencyAmplitudes[1][68] =  8'd0;
   assign songFrequencies        [2][68] = 14'd20400;
   assign songFrequencyAmplitudes[2][68] =  8'd0;
   //--
   assign songFrequencies        [0][69] = 14'd500;
   assign songFrequencyAmplitudes[0][69] =  8'd89;
   assign songFrequencies        [1][69] = 14'd12800;
   assign songFrequencyAmplitudes[1][69] =  8'd0;
   assign songFrequencies        [2][69] = 14'd20400;
   assign songFrequencyAmplitudes[2][69] =  8'd0;
   //--
   assign songFrequencies        [0][70] = 14'd500;
   assign songFrequencyAmplitudes[0][70] =  8'd89;
   assign songFrequencies        [1][70] = 14'd12800;
   assign songFrequencyAmplitudes[1][70] =  8'd0;
   assign songFrequencies        [2][70] = 14'd20400;
   assign songFrequencyAmplitudes[2][70] =  8'd0;
   //--
   assign songFrequencies        [0][71] = 14'd500;
   assign songFrequencyAmplitudes[0][71] =  8'd89;
   assign songFrequencies        [1][71] = 14'd12800;
   assign songFrequencyAmplitudes[1][71] =  8'd0;
   assign songFrequencies        [2][71] = 14'd20400;
   assign songFrequencyAmplitudes[2][71] =  8'd0;
   //--
   assign songFrequencies        [0][72] = 14'd500;
   assign songFrequencyAmplitudes[0][72] =  8'd89;
   assign songFrequencies        [1][72] = 14'd12800;
   assign songFrequencyAmplitudes[1][72] =  8'd0;
   assign songFrequencies        [2][72] = 14'd20400;
   assign songFrequencyAmplitudes[2][72] =  8'd0;
   //--
   assign songFrequencies        [0][73] = 14'd500;
   assign songFrequencyAmplitudes[0][73] =  8'd89;
   assign songFrequencies        [1][73] = 14'd12800;
   assign songFrequencyAmplitudes[1][73] =  8'd0;
   assign songFrequencies        [2][73] = 14'd20400;
   assign songFrequencyAmplitudes[2][73] =  8'd0;
   //--
   assign songFrequencies        [0][74] = 14'd500;
   assign songFrequencyAmplitudes[0][74] =  8'd89;
   assign songFrequencies        [1][74] = 14'd12800;
   assign songFrequencyAmplitudes[1][74] =  8'd0;
   assign songFrequencies        [2][74] = 14'd20400;
   assign songFrequencyAmplitudes[2][74] =  8'd0;
   //--
   assign songFrequencies        [0][75] = 14'd500;
   assign songFrequencyAmplitudes[0][75] =  8'd66;
   assign songFrequencies        [1][75] = 14'd493;
   assign songFrequencyAmplitudes[1][75] =  8'd20;
   assign songFrequencies        [2][75] = 14'd506;
   assign songFrequencyAmplitudes[2][75] =  8'd20;
   //--
   assign songFrequencies        [0][76] = 14'd500;
   assign songFrequencyAmplitudes[0][76] =  8'd36;
   assign songFrequencies        [1][76] = 14'd493;
   assign songFrequencyAmplitudes[1][76] =  8'd27;
   assign songFrequencies        [2][76] = 14'd506;
   assign songFrequencyAmplitudes[2][76] =  8'd27;
   //--
   assign songFrequencies        [0][77] = 14'd500;
   assign songFrequencyAmplitudes[0][77] =  8'd6;
   assign songFrequencies        [1][77] = 14'd493;
   assign songFrequencyAmplitudes[1][77] =  8'd6;
   assign songFrequencies        [2][77] = 14'd506;
   assign songFrequencyAmplitudes[2][77] =  8'd6;
   //--
   assign songFrequencies        [0][78] = 14'd0;
   assign songFrequencyAmplitudes[0][78] =  8'd0;
   assign songFrequencies        [1][78] = 14'd0;
   assign songFrequencyAmplitudes[1][78] =  8'd0;
   assign songFrequencies        [2][78] = 14'd0;
   assign songFrequencyAmplitudes[2][78] =  8'd0;
   //--
   assign songFrequencies        [0][79] = 14'd0;
   assign songFrequencyAmplitudes[0][79] =  8'd0;
   assign songFrequencies        [1][79] = 14'd0;
   assign songFrequencyAmplitudes[1][79] =  8'd0;
   assign songFrequencies        [2][79] = 14'd0;
   assign songFrequencyAmplitudes[2][79] =  8'd0;
   //--
   assign songFrequencies        [0][80] = 14'd0;
   assign songFrequencyAmplitudes[0][80] =  8'd0;
   assign songFrequencies        [1][80] = 14'd0;
   assign songFrequencyAmplitudes[1][80] =  8'd0;
   assign songFrequencies        [2][80] = 14'd0;
   assign songFrequencyAmplitudes[2][80] =  8'd0;
   //--
   assign songFrequencies        [0][81] = 14'd0;
   assign songFrequencyAmplitudes[0][81] =  8'd0;
   assign songFrequencies        [1][81] = 14'd0;
   assign songFrequencyAmplitudes[1][81] =  8'd0;
   assign songFrequencies        [2][81] = 14'd0;
   assign songFrequencyAmplitudes[2][81] =  8'd0;
   //--
   assign songFrequencies        [0][82] = 14'd0;
   assign songFrequencyAmplitudes[0][82] =  8'd0;
   assign songFrequencies        [1][82] = 14'd0;
   assign songFrequencyAmplitudes[1][82] =  8'd0;
   assign songFrequencies        [2][82] = 14'd0;
   assign songFrequencyAmplitudes[2][82] =  8'd0;
   //--
   assign songFrequencies        [0][83] = 14'd0;
   assign songFrequencyAmplitudes[0][83] =  8'd0;
   assign songFrequencies        [1][83] = 14'd6;
   assign songFrequencyAmplitudes[1][83] =  8'd0;
   assign songFrequencies        [2][83] = 14'd13;
   assign songFrequencyAmplitudes[2][83] =  8'd0;
   //--
   assign songFrequencies        [0][84] = 14'd500;
   assign songFrequencyAmplitudes[0][84] =  8'd30;
   assign songFrequencies        [1][84] = 14'd493;
   assign songFrequencyAmplitudes[1][84] =  8'd25;
   assign songFrequencies        [2][84] = 14'd506;
   assign songFrequencyAmplitudes[2][84] =  8'd24;
   //--
   assign songFrequencies        [0][85] = 14'd500;
   assign songFrequencyAmplitudes[0][85] =  8'd60;
   assign songFrequencies        [1][85] = 14'd493;
   assign songFrequencyAmplitudes[1][85] =  8'd24;
   assign songFrequencies        [2][85] = 14'd506;
   assign songFrequencyAmplitudes[2][85] =  8'd24;
   //--
   assign songFrequencies        [0][86] = 14'd500;
   assign songFrequencyAmplitudes[0][86] =  8'd89;
   assign songFrequencies        [1][86] = 14'd12800;
   assign songFrequencyAmplitudes[1][86] =  8'd0;
   assign songFrequencies        [2][86] = 14'd20400;
   assign songFrequencyAmplitudes[2][86] =  8'd0;
   //--
   assign songFrequencies        [0][87] = 14'd500;
   assign songFrequencyAmplitudes[0][87] =  8'd89;
   assign songFrequencies        [1][87] = 14'd12800;
   assign songFrequencyAmplitudes[1][87] =  8'd0;
   assign songFrequencies        [2][87] = 14'd20400;
   assign songFrequencyAmplitudes[2][87] =  8'd0;
   //--
   assign songFrequencies        [0][88] = 14'd500;
   assign songFrequencyAmplitudes[0][88] =  8'd89;
   assign songFrequencies        [1][88] = 14'd12800;
   assign songFrequencyAmplitudes[1][88] =  8'd0;
   assign songFrequencies        [2][88] = 14'd20400;
   assign songFrequencyAmplitudes[2][88] =  8'd0;
   //--
   assign songFrequencies        [0][89] = 14'd500;
   assign songFrequencyAmplitudes[0][89] =  8'd89;
   assign songFrequencies        [1][89] = 14'd12800;
   assign songFrequencyAmplitudes[1][89] =  8'd0;
   assign songFrequencies        [2][89] = 14'd20400;
   assign songFrequencyAmplitudes[2][89] =  8'd0;
   //--
   assign songFrequencies        [0][90] = 14'd500;
   assign songFrequencyAmplitudes[0][90] =  8'd89;
   assign songFrequencies        [1][90] = 14'd12800;
   assign songFrequencyAmplitudes[1][90] =  8'd0;
   assign songFrequencies        [2][90] = 14'd20400;
   assign songFrequencyAmplitudes[2][90] =  8'd0;
   //--
   assign songFrequencies        [0][91] = 14'd500;
   assign songFrequencyAmplitudes[0][91] =  8'd89;
   assign songFrequencies        [1][91] = 14'd12800;
   assign songFrequencyAmplitudes[1][91] =  8'd0;
   assign songFrequencies        [2][91] = 14'd20400;
   assign songFrequencyAmplitudes[2][91] =  8'd0;
   //--
   assign songFrequencies        [0][92] = 14'd500;
   assign songFrequencyAmplitudes[0][92] =  8'd89;
   assign songFrequencies        [1][92] = 14'd12800;
   assign songFrequencyAmplitudes[1][92] =  8'd0;
   assign songFrequencies        [2][92] = 14'd20400;
   assign songFrequencyAmplitudes[2][92] =  8'd0;
   //--
   assign songFrequencies        [0][93] = 14'd500;
   assign songFrequencyAmplitudes[0][93] =  8'd89;
   assign songFrequencies        [1][93] = 14'd12800;
   assign songFrequencyAmplitudes[1][93] =  8'd0;
   assign songFrequencies        [2][93] = 14'd20400;
   assign songFrequencyAmplitudes[2][93] =  8'd0;
   //--
   assign songFrequencies        [0][94] = 14'd500;
   assign songFrequencyAmplitudes[0][94] =  8'd89;
   assign songFrequencies        [1][94] = 14'd12800;
   assign songFrequencyAmplitudes[1][94] =  8'd0;
   assign songFrequencies        [2][94] = 14'd20400;
   assign songFrequencyAmplitudes[2][94] =  8'd0;
   //--
   assign songFrequencies        [0][95] = 14'd500;
   assign songFrequencyAmplitudes[0][95] =  8'd89;
   assign songFrequencies        [1][95] = 14'd12800;
   assign songFrequencyAmplitudes[1][95] =  8'd0;
   assign songFrequencies        [2][95] = 14'd20400;
   assign songFrequencyAmplitudes[2][95] =  8'd0;
   //--
   assign songFrequencies        [0][96] = 14'd500;
   assign songFrequencyAmplitudes[0][96] =  8'd89;
   assign songFrequencies        [1][96] = 14'd12800;
   assign songFrequencyAmplitudes[1][96] =  8'd0;
   assign songFrequencies        [2][96] = 14'd20400;
   assign songFrequencyAmplitudes[2][96] =  8'd0;
   //--
   assign songFrequencies        [0][97] = 14'd500;
   assign songFrequencyAmplitudes[0][97] =  8'd89;
   assign songFrequencies        [1][97] = 14'd12800;
   assign songFrequencyAmplitudes[1][97] =  8'd0;
   assign songFrequencies        [2][97] = 14'd20400;
   assign songFrequencyAmplitudes[2][97] =  8'd0;
   //--
   assign songFrequencies        [0][98] = 14'd500;
   assign songFrequencyAmplitudes[0][98] =  8'd89;
   assign songFrequencies        [1][98] = 14'd12800;
   assign songFrequencyAmplitudes[1][98] =  8'd0;
   assign songFrequencies        [2][98] = 14'd20400;
   assign songFrequencyAmplitudes[2][98] =  8'd0;
   //--
endmodule
