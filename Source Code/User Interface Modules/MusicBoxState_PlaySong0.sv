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
				if (songIndexCounter == 184 -1) begin
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
bit [2:0][184:0][13:0] songFrequencies;
bit [2:0][184:0][7:0] songFrequencyAmplitudes;

//-=-=-=-=-SONG DATA-=-=-=-=- 
   assign songFrequencies        [0][0] = 14'd226;
   assign songFrequencyAmplitudes[0][0] =  8'd79;
   assign songFrequencies        [1][0] = 14'd213;
   assign songFrequencyAmplitudes[1][0] =  8'd79;
   assign songFrequencies        [2][0] = 14'd206;
   assign songFrequencyAmplitudes[2][0] =  8'd71;
   //--
   assign songFrequencies        [0][1] = 14'd240;
   assign songFrequencyAmplitudes[0][1] =  8'd85;
   assign songFrequencies        [1][1] = 14'd226;
   assign songFrequencyAmplitudes[1][1] =  8'd85;
   assign songFrequencies        [2][1] = 14'd220;
   assign songFrequencyAmplitudes[2][1] =  8'd68;
   //--
   assign songFrequencies        [0][2] = 14'd240;
   assign songFrequencyAmplitudes[0][2] =  8'd89;
   assign songFrequencies        [1][2] = 14'd253;
   assign songFrequencyAmplitudes[1][2] =  8'd89;
   assign songFrequencies        [2][2] = 14'd233;
   assign songFrequencyAmplitudes[2][2] =  8'd68;
   //--
   assign songFrequencies        [0][3] = 14'd253;
   assign songFrequencyAmplitudes[0][3] =  8'd87;
   assign songFrequencies        [1][3] = 14'd266;
   assign songFrequencyAmplitudes[1][3] =  8'd87;
   assign songFrequencies        [2][3] = 14'd273;
   assign songFrequencyAmplitudes[2][3] =  8'd67;
   //--
   assign songFrequencies        [0][4] = 14'd266;
   assign songFrequencyAmplitudes[0][4] =  8'd81;
   assign songFrequencies        [1][4] = 14'd280;
   assign songFrequencyAmplitudes[1][4] =  8'd81;
   assign songFrequencies        [2][4] = 14'd286;
   assign songFrequencyAmplitudes[2][4] =  8'd68;
   //--
   assign songFrequencies        [0][5] = 14'd280;
   assign songFrequencyAmplitudes[0][5] =  8'd74;
   assign songFrequencies        [1][5] = 14'd300;
   assign songFrequencyAmplitudes[1][5] =  8'd72;
   assign songFrequencies        [2][5] = 14'd293;
   assign songFrequencyAmplitudes[2][5] =  8'd71;
   //--
   assign songFrequencies        [0][6] = 14'd313;
   assign songFrequencyAmplitudes[0][6] =  8'd79;
   assign songFrequencies        [1][6] = 14'd300;
   assign songFrequencyAmplitudes[1][6] =  8'd79;
   assign songFrequencies        [2][6] = 14'd293;
   assign songFrequencyAmplitudes[2][6] =  8'd68;
   //--
   assign songFrequencies        [0][7] = 14'd313;
   assign songFrequencyAmplitudes[0][7] =  8'd85;
   assign songFrequencies        [1][7] = 14'd326;
   assign songFrequencyAmplitudes[1][7] =  8'd85;
   assign songFrequencies        [2][7] = 14'd306;
   assign songFrequencyAmplitudes[2][7] =  8'd67;
   //--
   assign songFrequencies        [0][8] = 14'd326;
   assign songFrequencyAmplitudes[0][8] =  8'd87;
   assign songFrequencies        [1][8] = 14'd340;
   assign songFrequencyAmplitudes[1][8] =  8'd87;
   assign songFrequencies        [2][8] = 14'd320;
   assign songFrequencyAmplitudes[2][8] =  8'd67;
   //--
   assign songFrequencies        [0][9] = 14'd340;
   assign songFrequencyAmplitudes[0][9] =  8'd84;
   assign songFrequencies        [1][9] = 14'd353;
   assign songFrequencyAmplitudes[1][9] =  8'd84;
   assign songFrequencies        [2][9] = 14'd360;
   assign songFrequencyAmplitudes[2][9] =  8'd66;
   //--
   assign songFrequencies        [0][10] = 14'd353;
   assign songFrequencyAmplitudes[0][10] =  8'd77;
   assign songFrequencies        [1][10] = 14'd366;
   assign songFrequencyAmplitudes[1][10] =  8'd76;
   assign songFrequencies        [2][10] = 14'd373;
   assign songFrequencyAmplitudes[2][10] =  8'd67;
   //--
   assign songFrequencies        [0][11] = 14'd386;
   assign songFrequencyAmplitudes[0][11] =  8'd73;
   assign songFrequencies        [1][11] = 14'd373;
   assign songFrequencyAmplitudes[1][11] =  8'd72;
   assign songFrequencies        [2][11] = 14'd366;
   assign songFrequencyAmplitudes[2][11] =  8'd71;
   //--
   assign songFrequencies        [0][12] = 14'd400;
   assign songFrequencyAmplitudes[0][12] =  8'd80;
   assign songFrequencies        [1][12] = 14'd386;
   assign songFrequencyAmplitudes[1][12] =  8'd80;
   assign songFrequencies        [2][12] = 14'd380;
   assign songFrequencyAmplitudes[2][12] =  8'd66;
   //--
   assign songFrequencies        [0][13] = 14'd400;
   assign songFrequencyAmplitudes[0][13] =  8'd85;
   assign songFrequencies        [1][13] = 14'd413;
   assign songFrequencyAmplitudes[1][13] =  8'd85;
   assign songFrequencies        [2][13] = 14'd393;
   assign songFrequencyAmplitudes[2][13] =  8'd65;
   //--
   assign songFrequencies        [0][14] = 14'd413;
   assign songFrequencyAmplitudes[0][14] =  8'd85;
   assign songFrequencies        [1][14] = 14'd426;
   assign songFrequencyAmplitudes[1][14] =  8'd85;
   assign songFrequencies        [2][14] = 14'd406;
   assign songFrequencyAmplitudes[2][14] =  8'd65;
   //--
   assign songFrequencies        [0][15] = 14'd426;
   assign songFrequencyAmplitudes[0][15] =  8'd81;
   assign songFrequencies        [1][15] = 14'd440;
   assign songFrequencyAmplitudes[1][15] =  8'd80;
   assign songFrequencies        [2][15] = 14'd446;
   assign songFrequencyAmplitudes[2][15] =  8'd65;
   //--
   assign songFrequencies        [0][16] = 14'd440;
   assign songFrequencyAmplitudes[0][16] =  8'd74;
   assign songFrequencies        [1][16] = 14'd453;
   assign songFrequencyAmplitudes[1][16] =  8'd73;
   assign songFrequencies        [2][16] = 14'd460;
   assign songFrequencyAmplitudes[2][16] =  8'd67;
   //--
   assign songFrequencies        [0][17] = 14'd473;
   assign songFrequencyAmplitudes[0][17] =  8'd74;
   assign songFrequencies        [1][17] = 14'd460;
   assign songFrequencyAmplitudes[1][17] =  8'd73;
   assign songFrequencies        [2][17] = 14'd453;
   assign songFrequencyAmplitudes[2][17] =  8'd67;
   //--
   assign songFrequencies        [0][18] = 14'd486;
   assign songFrequencyAmplitudes[0][18] =  8'd80;
   assign songFrequencies        [1][18] = 14'd473;
   assign songFrequencyAmplitudes[1][18] =  8'd80;
   assign songFrequencies        [2][18] = 14'd466;
   assign songFrequencyAmplitudes[2][18] =  8'd64;
   //--
   assign songFrequencies        [0][19] = 14'd486;
   assign songFrequencyAmplitudes[0][19] =  8'd84;
   assign songFrequencies        [1][19] = 14'd500;
   assign songFrequencyAmplitudes[1][19] =  8'd84;
   assign songFrequencies        [2][19] = 14'd480;
   assign songFrequencyAmplitudes[2][19] =  8'd64;
   //--
   assign songFrequencies        [0][20] = 14'd500;
   assign songFrequencyAmplitudes[0][20] =  8'd83;
   assign songFrequencies        [1][20] = 14'd513;
   assign songFrequencyAmplitudes[1][20] =  8'd82;
   assign songFrequencies        [2][20] = 14'd493;
   assign songFrequencyAmplitudes[2][20] =  8'd63;
   //--
   assign songFrequencies        [0][21] = 14'd513;
   assign songFrequencyAmplitudes[0][21] =  8'd78;
   assign songFrequencies        [1][21] = 14'd526;
   assign songFrequencyAmplitudes[1][21] =  8'd77;
   assign songFrequencies        [2][21] = 14'd533;
   assign songFrequencyAmplitudes[2][21] =  8'd64;
   //--
   assign songFrequencies        [0][22] = 14'd526;
   assign songFrequencyAmplitudes[0][22] =  8'd70;
   assign songFrequencies        [1][22] = 14'd540;
   assign songFrequencyAmplitudes[1][22] =  8'd69;
   assign songFrequencies        [2][22] = 14'd546;
   assign songFrequencyAmplitudes[2][22] =  8'd68;
   //--
   assign songFrequencies        [0][23] = 14'd560;
   assign songFrequencyAmplitudes[0][23] =  8'd74;
   assign songFrequencies        [1][23] = 14'd546;
   assign songFrequencyAmplitudes[1][23] =  8'd73;
   assign songFrequencies        [2][23] = 14'd540;
   assign songFrequencyAmplitudes[2][23] =  8'd65;
   //--
   assign songFrequencies        [0][24] = 14'd560;
   assign songFrequencyAmplitudes[0][24] =  8'd80;
   assign songFrequencies        [1][24] = 14'd573;
   assign songFrequencyAmplitudes[1][24] =  8'd80;
   assign songFrequencies        [2][24] = 14'd553;
   assign songFrequencyAmplitudes[2][24] =  8'd63;
   //--
   assign songFrequencies        [0][25] = 14'd573;
   assign songFrequencyAmplitudes[0][25] =  8'd82;
   assign songFrequencies        [1][25] = 14'd586;
   assign songFrequencyAmplitudes[1][25] =  8'd82;
   assign songFrequencies        [2][25] = 14'd566;
   assign songFrequencyAmplitudes[2][25] =  8'd63;
   //--
   assign songFrequencies        [0][26] = 14'd586;
   assign songFrequencyAmplitudes[0][26] =  8'd80;
   assign songFrequencies        [1][26] = 14'd600;
   assign songFrequencyAmplitudes[1][26] =  8'd80;
   assign songFrequencies        [2][26] = 14'd606;
   assign songFrequencyAmplitudes[2][26] =  8'd62;
   //--
   assign songFrequencies        [0][27] = 14'd600;
   assign songFrequencyAmplitudes[0][27] =  8'd74;
   assign songFrequencies        [1][27] = 14'd613;
   assign songFrequencyAmplitudes[1][27] =  8'd74;
   assign songFrequencies        [2][27] = 14'd620;
   assign songFrequencyAmplitudes[2][27] =  8'd63;
   //--
   assign songFrequencies        [0][28] = 14'd633;
   assign songFrequencyAmplitudes[0][28] =  8'd68;
   assign songFrequencies        [1][28] = 14'd613;
   assign songFrequencyAmplitudes[1][28] =  8'd67;
   assign songFrequencies        [2][28] = 14'd620;
   assign songFrequencyAmplitudes[2][28] =  8'd67;
   //--
   assign songFrequencies        [0][29] = 14'd646;
   assign songFrequencyAmplitudes[0][29] =  8'd75;
   assign songFrequencies        [1][29] = 14'd633;
   assign songFrequencyAmplitudes[1][29] =  8'd74;
   assign songFrequencies        [2][29] = 14'd626;
   assign songFrequencyAmplitudes[2][29] =  8'd63;
   //--
   assign songFrequencies        [0][30] = 14'd646;
   assign songFrequencyAmplitudes[0][30] =  8'd80;
   assign songFrequencies        [1][30] = 14'd660;
   assign songFrequencyAmplitudes[1][30] =  8'd79;
   assign songFrequencies        [2][30] = 14'd640;
   assign songFrequencyAmplitudes[2][30] =  8'd62;
   //--
   assign songFrequencies        [0][31] = 14'd660;
   assign songFrequencyAmplitudes[0][31] =  8'd81;
   assign songFrequencies        [1][31] = 14'd673;
   assign songFrequencyAmplitudes[1][31] =  8'd80;
   assign songFrequencies        [2][31] = 14'd653;
   assign songFrequencyAmplitudes[2][31] =  8'd62;
   //--
   assign songFrequencies        [0][32] = 14'd673;
   assign songFrequencyAmplitudes[0][32] =  8'd77;
   assign songFrequencies        [1][32] = 14'd686;
   assign songFrequencyAmplitudes[1][32] =  8'd77;
   assign songFrequencies        [2][32] = 14'd693;
   assign songFrequencyAmplitudes[2][32] =  8'd61;
   //--
   assign songFrequencies        [0][33] = 14'd686;
   assign songFrequencyAmplitudes[0][33] =  8'd71;
   assign songFrequencies        [1][33] = 14'd700;
   assign songFrequencyAmplitudes[1][33] =  8'd69;
   assign songFrequencies        [2][33] = 14'd706;
   assign songFrequencyAmplitudes[2][33] =  8'd63;
   //--
   assign songFrequencies        [0][34] = 14'd720;
   assign songFrequencyAmplitudes[0][34] =  8'd69;
   assign songFrequencies        [1][34] = 14'd706;
   assign songFrequencyAmplitudes[1][34] =  8'd67;
   assign songFrequencies        [2][34] = 14'd700;
   assign songFrequencyAmplitudes[2][34] =  8'd64;
   //--
   assign songFrequencies        [0][35] = 14'd720;
   assign songFrequencyAmplitudes[0][35] =  8'd75;
   assign songFrequencies        [1][35] = 14'd733;
   assign songFrequencyAmplitudes[1][35] =  8'd75;
   assign songFrequencies        [2][35] = 14'd713;
   assign songFrequencyAmplitudes[2][35] =  8'd61;
   //--
   assign songFrequencies        [0][36] = 14'd733;
   assign songFrequencyAmplitudes[0][36] =  8'd79;
   assign songFrequencies        [1][36] = 14'd746;
   assign songFrequencyAmplitudes[1][36] =  8'd79;
   assign songFrequencies        [2][36] = 14'd726;
   assign songFrequencyAmplitudes[2][36] =  8'd61;
   //--
   assign songFrequencies        [0][37] = 14'd746;
   assign songFrequencyAmplitudes[0][37] =  8'd79;
   assign songFrequencies        [1][37] = 14'd760;
   assign songFrequencyAmplitudes[1][37] =  8'd78;
   assign songFrequencies        [2][37] = 14'd740;
   assign songFrequencyAmplitudes[2][37] =  8'd60;
   //--
   assign songFrequencies        [0][38] = 14'd760;
   assign songFrequencyAmplitudes[0][38] =  8'd74;
   assign songFrequencies        [1][38] = 14'd773;
   assign songFrequencyAmplitudes[1][38] =  8'd73;
   assign songFrequencies        [2][38] = 14'd780;
   assign songFrequencyAmplitudes[2][38] =  8'd60;
   //--
   assign songFrequencies        [0][39] = 14'd773;
   assign songFrequencyAmplitudes[0][39] =  8'd68;
   assign songFrequencies        [1][39] = 14'd786;
   assign songFrequencyAmplitudes[1][39] =  8'd66;
   assign songFrequencies        [2][39] = 14'd793;
   assign songFrequencyAmplitudes[2][39] =  8'd63;
   //--
   assign songFrequencies        [0][40] = 14'd806;
   assign songFrequencyAmplitudes[0][40] =  8'd69;
   assign songFrequencies        [1][40] = 14'd793;
   assign songFrequencyAmplitudes[1][40] =  8'd68;
   assign songFrequencies        [2][40] = 14'd786;
   assign songFrequencyAmplitudes[2][40] =  8'd62;
   //--
   assign songFrequencies        [0][41] = 14'd806;
   assign songFrequencyAmplitudes[0][41] =  8'd75;
   assign songFrequencies        [1][41] = 14'd820;
   assign songFrequencyAmplitudes[1][41] =  8'd75;
   assign songFrequencies        [2][41] = 14'd800;
   assign songFrequencyAmplitudes[2][41] =  8'd59;
   //--
   assign songFrequencies        [0][42] = 14'd820;
   assign songFrequencyAmplitudes[0][42] =  8'd78;
   assign songFrequencies        [1][42] = 14'd833;
   assign songFrequencyAmplitudes[1][42] =  8'd77;
   assign songFrequencies        [2][42] = 14'd813;
   assign songFrequencyAmplitudes[2][42] =  8'd59;
   //--
   assign songFrequencies        [0][43] = 14'd833;
   assign songFrequencyAmplitudes[0][43] =  8'd76;
   assign songFrequencies        [1][43] = 14'd846;
   assign songFrequencyAmplitudes[1][43] =  8'd76;
   assign songFrequencies        [2][43] = 14'd853;
   assign songFrequencyAmplitudes[2][43] =  8'd59;
   //--
   assign songFrequencies        [0][44] = 14'd846;
   assign songFrequencyAmplitudes[0][44] =  8'd71;
   assign songFrequencies        [1][44] = 14'd860;
   assign songFrequencyAmplitudes[1][44] =  8'd70;
   assign songFrequencies        [2][44] = 14'd866;
   assign songFrequencyAmplitudes[2][44] =  8'd60;
   //--
   assign songFrequencies        [0][45] = 14'd860;
   assign songFrequencyAmplitudes[0][45] =  8'd64;
   assign songFrequencies        [1][45] = 14'd880;
   assign songFrequencyAmplitudes[1][45] =  8'd63;
   assign songFrequencies        [2][45] = 14'd873;
   assign songFrequencyAmplitudes[2][45] =  8'd62;
   //--
   assign songFrequencies        [0][46] = 14'd893;
   assign songFrequencyAmplitudes[0][46] =  8'd69;
   assign songFrequencies        [1][46] = 14'd880;
   assign songFrequencyAmplitudes[1][46] =  8'd69;
   assign songFrequencies        [2][46] = 14'd873;
   assign songFrequencyAmplitudes[2][46] =  8'd60;
   //--
   assign songFrequencies        [0][47] = 14'd893;
   assign songFrequencyAmplitudes[0][47] =  8'd74;
   assign songFrequencies        [1][47] = 14'd906;
   assign songFrequencyAmplitudes[1][47] =  8'd74;
   assign songFrequencies        [2][47] = 14'd886;
   assign songFrequencyAmplitudes[2][47] =  8'd58;
   //--
   assign songFrequencies        [0][48] = 14'd906;
   assign songFrequencyAmplitudes[0][48] =  8'd76;
   assign songFrequencies        [1][48] = 14'd920;
   assign songFrequencyAmplitudes[1][48] =  8'd76;
   assign songFrequencies        [2][48] = 14'd900;
   assign songFrequencyAmplitudes[2][48] =  8'd58;
   //--
   assign songFrequencies        [0][49] = 14'd920;
   assign songFrequencyAmplitudes[0][49] =  8'd73;
   assign songFrequencies        [1][49] = 14'd933;
   assign songFrequencyAmplitudes[1][49] =  8'd73;
   assign songFrequencies        [2][49] = 14'd940;
   assign songFrequencyAmplitudes[2][49] =  8'd57;
   //--
   assign songFrequencies        [0][50] = 14'd933;
   assign songFrequencyAmplitudes[0][50] =  8'd68;
   assign songFrequencies        [1][50] = 14'd946;
   assign songFrequencyAmplitudes[1][50] =  8'd67;
   assign songFrequencies        [2][50] = 14'd953;
   assign songFrequencyAmplitudes[2][50] =  8'd59;
   //--
   assign songFrequencies        [0][51] = 14'd966;
   assign songFrequencyAmplitudes[0][51] =  8'd63;
   assign songFrequencies        [1][51] = 14'd953;
   assign songFrequencyAmplitudes[1][51] =  8'd62;
   assign songFrequencies        [2][51] = 14'd946;
   assign songFrequencyAmplitudes[2][51] =  8'd62;
   //--
   assign songFrequencies        [0][52] = 14'd980;
   assign songFrequencyAmplitudes[0][52] =  8'd70;
   assign songFrequencies        [1][52] = 14'd966;
   assign songFrequencyAmplitudes[1][52] =  8'd70;
   assign songFrequencies        [2][52] = 14'd960;
   assign songFrequencyAmplitudes[2][52] =  8'd58;
   //--
   assign songFrequencies        [0][53] = 14'd980;
   assign songFrequencyAmplitudes[0][53] =  8'd74;
   assign songFrequencies        [1][53] = 14'd993;
   assign songFrequencyAmplitudes[1][53] =  8'd74;
   assign songFrequencies        [2][53] = 14'd973;
   assign songFrequencyAmplitudes[2][53] =  8'd57;
   //--
   assign songFrequencies        [0][54] = 14'd993;
   assign songFrequencyAmplitudes[0][54] =  8'd74;
   assign songFrequencies        [1][54] = 14'd1006;
   assign songFrequencyAmplitudes[1][54] =  8'd74;
   assign songFrequencies        [2][54] = 14'd986;
   assign songFrequencyAmplitudes[2][54] =  8'd57;
   //--
   assign songFrequencies        [0][55] = 14'd1006;
   assign songFrequencyAmplitudes[0][55] =  8'd70;
   assign songFrequencies        [1][55] = 14'd1020;
   assign songFrequencyAmplitudes[1][55] =  8'd70;
   assign songFrequencies        [2][55] = 14'd1026;
   assign songFrequencyAmplitudes[2][55] =  8'd56;
   //--
   assign songFrequencies        [0][56] = 14'd1020;
   assign songFrequencyAmplitudes[0][56] =  8'd64;
   assign songFrequencies        [1][56] = 14'd1033;
   assign songFrequencyAmplitudes[1][56] =  8'd63;
   assign songFrequencies        [2][56] = 14'd1040;
   assign songFrequencyAmplitudes[2][56] =  8'd59;
   //--
   assign songFrequencies        [0][57] = 14'd1053;
   assign songFrequencyAmplitudes[0][57] =  8'd64;
   assign songFrequencies        [1][57] = 14'd1040;
   assign songFrequencyAmplitudes[1][57] =  8'd63;
   assign songFrequencies        [2][57] = 14'd1033;
   assign songFrequencyAmplitudes[2][57] =  8'd59;
   //--
   assign songFrequencies        [0][58] = 14'd1053;
   assign songFrequencyAmplitudes[0][58] =  8'd70;
   assign songFrequencies        [1][58] = 14'd1066;
   assign songFrequencyAmplitudes[1][58] =  8'd70;
   assign songFrequencies        [2][58] = 14'd1046;
   assign songFrequencyAmplitudes[2][58] =  8'd56;
   //--
   assign songFrequencies        [0][59] = 14'd1066;
   assign songFrequencyAmplitudes[0][59] =  8'd73;
   assign songFrequencies        [1][59] = 14'd1080;
   assign songFrequencyAmplitudes[1][59] =  8'd73;
   assign songFrequencies        [2][59] = 14'd1060;
   assign songFrequencyAmplitudes[2][59] =  8'd56;
   //--
   assign songFrequencies        [0][60] = 14'd1080;
   assign songFrequencyAmplitudes[0][60] =  8'd72;
   assign songFrequencies        [1][60] = 14'd1093;
   assign songFrequencyAmplitudes[1][60] =  8'd72;
   assign songFrequencies        [2][60] = 14'd1073;
   assign songFrequencyAmplitudes[2][60] =  8'd55;
   //--
   assign songFrequencies        [0][61] = 14'd1093;
   assign songFrequencyAmplitudes[0][61] =  8'd67;
   assign songFrequencies        [1][61] = 14'd1106;
   assign songFrequencyAmplitudes[1][61] =  8'd67;
   assign songFrequencies        [2][61] = 14'd1113;
   assign songFrequencyAmplitudes[2][61] =  8'd56;
   //--
   assign songFrequencies        [0][62] = 14'd1106;
   assign songFrequencyAmplitudes[0][62] =  8'd61;
   assign songFrequencies        [1][62] = 14'd1120;
   assign songFrequencyAmplitudes[1][62] =  8'd59;
   assign songFrequencies        [2][62] = 14'd1126;
   assign songFrequencyAmplitudes[2][62] =  8'd59;
   //--
   assign songFrequencies        [0][63] = 14'd1140;
   assign songFrequencyAmplitudes[0][63] =  8'd64;
   assign songFrequencies        [1][63] = 14'd1126;
   assign songFrequencyAmplitudes[1][63] =  8'd64;
   assign songFrequencies        [2][63] = 14'd1120;
   assign songFrequencyAmplitudes[2][63] =  8'd56;
   //--
   assign songFrequencies        [0][64] = 14'd1140;
   assign songFrequencyAmplitudes[0][64] =  8'd69;
   assign songFrequencies        [1][64] = 14'd1153;
   assign songFrequencyAmplitudes[1][64] =  8'd69;
   assign songFrequencies        [2][64] = 14'd1133;
   assign songFrequencyAmplitudes[2][64] =  8'd55;
   //--
   assign songFrequencies        [0][65] = 14'd1153;
   assign songFrequencyAmplitudes[0][65] =  8'd71;
   assign songFrequencies        [1][65] = 14'd1166;
   assign songFrequencyAmplitudes[1][65] =  8'd71;
   assign songFrequencies        [2][65] = 14'd1146;
   assign songFrequencyAmplitudes[2][65] =  8'd55;
   //--
   assign songFrequencies        [0][66] = 14'd1166;
   assign songFrequencyAmplitudes[0][66] =  8'd69;
   assign songFrequencies        [1][66] = 14'd1180;
   assign songFrequencyAmplitudes[1][66] =  8'd69;
   assign songFrequencies        [2][66] = 14'd1186;
   assign songFrequencyAmplitudes[2][66] =  8'd54;
   //--
   assign songFrequencies        [0][67] = 14'd1180;
   assign songFrequencyAmplitudes[0][67] =  8'd64;
   assign songFrequencies        [1][67] = 14'd1193;
   assign songFrequencyAmplitudes[1][67] =  8'd63;
   assign songFrequencies        [2][67] = 14'd1200;
   assign songFrequencyAmplitudes[2][67] =  8'd55;
   //--
   assign songFrequencies        [0][68] = 14'd1213;
   assign songFrequencyAmplitudes[0][68] =  8'd59;
   assign songFrequencies        [1][68] = 14'd1193;
   assign songFrequencyAmplitudes[1][68] =  8'd58;
   assign songFrequencies        [2][68] = 14'd1200;
   assign songFrequencyAmplitudes[2][68] =  8'd58;
   //--
   assign songFrequencies        [0][69] = 14'd1226;
   assign songFrequencyAmplitudes[0][69] =  8'd64;
   assign songFrequencies        [1][69] = 14'd1213;
   assign songFrequencyAmplitudes[1][69] =  8'd64;
   assign songFrequencies        [2][69] = 14'd1206;
   assign songFrequencyAmplitudes[2][69] =  8'd54;
   //--
   assign songFrequencies        [0][70] = 14'd1226;
   assign songFrequencyAmplitudes[0][70] =  8'd69;
   assign songFrequencies        [1][70] = 14'd1240;
   assign songFrequencyAmplitudes[1][70] =  8'd69;
   assign songFrequencies        [2][70] = 14'd1220;
   assign songFrequencyAmplitudes[2][70] =  8'd53;
   //--
   assign songFrequencies        [0][71] = 14'd1240;
   assign songFrequencyAmplitudes[0][71] =  8'd70;
   assign songFrequencies        [1][71] = 14'd1253;
   assign songFrequencyAmplitudes[1][71] =  8'd69;
   assign songFrequencies        [2][71] = 14'd1233;
   assign songFrequencyAmplitudes[2][71] =  8'd53;
   //--
   assign songFrequencies        [0][72] = 14'd1253;
   assign songFrequencyAmplitudes[0][72] =  8'd67;
   assign songFrequencies        [1][72] = 14'd1266;
   assign songFrequencyAmplitudes[1][72] =  8'd66;
   assign songFrequencies        [2][72] = 14'd1273;
   assign songFrequencyAmplitudes[2][72] =  8'd53;
   //--
   assign songFrequencies        [0][73] = 14'd1266;
   assign songFrequencyAmplitudes[0][73] =  8'd61;
   assign songFrequencies        [1][73] = 14'd1280;
   assign songFrequencyAmplitudes[1][73] =  8'd60;
   assign songFrequencies        [2][73] = 14'd1286;
   assign songFrequencyAmplitudes[2][73] =  8'd54;
   //--
   assign songFrequencies        [0][74] = 14'd1300;
   assign songFrequencyAmplitudes[0][74] =  8'd59;
   assign songFrequencies        [1][74] = 14'd1286;
   assign songFrequencyAmplitudes[1][74] =  8'd58;
   assign songFrequencies        [2][74] = 14'd1280;
   assign songFrequencyAmplitudes[2][74] =  8'd55;
   //--
   assign songFrequencies        [0][75] = 14'd1300;
   assign songFrequencyAmplitudes[0][75] =  8'd64;
   assign songFrequencies        [1][75] = 14'd1313;
   assign songFrequencyAmplitudes[1][75] =  8'd64;
   assign songFrequencies        [2][75] = 14'd1293;
   assign songFrequencyAmplitudes[2][75] =  8'd53;
   //--
   assign songFrequencies        [0][76] = 14'd1313;
   assign songFrequencyAmplitudes[0][76] =  8'd68;
   assign songFrequencies        [1][76] = 14'd1326;
   assign songFrequencyAmplitudes[1][76] =  8'd68;
   assign songFrequencies        [2][76] = 14'd1306;
   assign songFrequencyAmplitudes[2][76] =  8'd52;
   //--
   assign songFrequencies        [0][77] = 14'd1326;
   assign songFrequencyAmplitudes[0][77] =  8'd68;
   assign songFrequencies        [1][77] = 14'd1340;
   assign songFrequencyAmplitudes[1][77] =  8'd67;
   assign songFrequencies        [2][77] = 14'd1320;
   assign songFrequencyAmplitudes[2][77] =  8'd52;
   //--
   assign songFrequencies        [0][78] = 14'd1340;
   assign songFrequencyAmplitudes[0][78] =  8'd64;
   assign songFrequencies        [1][78] = 14'd1353;
   assign songFrequencyAmplitudes[1][78] =  8'd63;
   assign songFrequencies        [2][78] = 14'd1360;
   assign songFrequencyAmplitudes[2][78] =  8'd52;
   //--
   assign songFrequencies        [0][79] = 14'd1353;
   assign songFrequencyAmplitudes[0][79] =  8'd58;
   assign songFrequencies        [1][79] = 14'd1366;
   assign songFrequencyAmplitudes[1][79] =  8'd57;
   assign songFrequencies        [2][79] = 14'd1373;
   assign songFrequencyAmplitudes[2][79] =  8'd54;
   //--
   assign songFrequencies        [0][80] = 14'd1386;
   assign songFrequencyAmplitudes[0][80] =  8'd59;
   assign songFrequencies        [1][80] = 14'd1373;
   assign songFrequencyAmplitudes[1][80] =  8'd59;
   assign songFrequencies        [2][80] = 14'd1366;
   assign songFrequencyAmplitudes[2][80] =  8'd53;
   //--
   assign songFrequencies        [0][81] = 14'd1386;
   assign songFrequencyAmplitudes[0][81] =  8'd64;
   assign songFrequencies        [1][81] = 14'd1400;
   assign songFrequencyAmplitudes[1][81] =  8'd64;
   assign songFrequencies        [2][81] = 14'd1380;
   assign songFrequencyAmplitudes[2][81] =  8'd51;
   //--
   assign songFrequencies        [0][82] = 14'd1400;
   assign songFrequencyAmplitudes[0][82] =  8'd67;
   assign songFrequencies        [1][82] = 14'd1413;
   assign songFrequencyAmplitudes[1][82] =  8'd66;
   assign songFrequencies        [2][82] = 14'd1393;
   assign songFrequencyAmplitudes[2][82] =  8'd51;
   //--
   assign songFrequencies        [0][83] = 14'd1413;
   assign songFrequencyAmplitudes[0][83] =  8'd65;
   assign songFrequencies        [1][83] = 14'd1426;
   assign songFrequencyAmplitudes[1][83] =  8'd65;
   assign songFrequencies        [2][83] = 14'd1433;
   assign songFrequencyAmplitudes[2][83] =  8'd50;
   //--
   assign songFrequencies        [0][84] = 14'd1426;
   assign songFrequencyAmplitudes[0][84] =  8'd61;
   assign songFrequencies        [1][84] = 14'd1440;
   assign songFrequencyAmplitudes[1][84] =  8'd60;
   assign songFrequencies        [2][84] = 14'd1446;
   assign songFrequencyAmplitudes[2][84] =  8'd51;
   //--
   assign songFrequencies        [0][85] = 14'd1440;
   assign songFrequencyAmplitudes[0][85] =  8'd55;
   assign songFrequencies        [1][85] = 14'd1460;
   assign songFrequencyAmplitudes[1][85] =  8'd54;
   assign songFrequencies        [2][85] = 14'd1453;
   assign songFrequencyAmplitudes[2][85] =  8'd53;
   //--
   assign songFrequencies        [0][86] = 14'd1473;
   assign songFrequencyAmplitudes[0][86] =  8'd59;
   assign songFrequencies        [1][86] = 14'd1460;
   assign songFrequencyAmplitudes[1][86] =  8'd59;
   assign songFrequencies        [2][86] = 14'd1453;
   assign songFrequencyAmplitudes[2][86] =  8'd51;
   //--
   assign songFrequencies        [0][87] = 14'd1473;
   assign songFrequencyAmplitudes[0][87] =  8'd64;
   assign songFrequencies        [1][87] = 14'd1486;
   assign songFrequencyAmplitudes[1][87] =  8'd64;
   assign songFrequencies        [2][87] = 14'd1466;
   assign songFrequencyAmplitudes[2][87] =  8'd50;
   //--
   assign songFrequencies        [0][88] = 14'd1486;
   assign songFrequencyAmplitudes[0][88] =  8'd65;
   assign songFrequencies        [1][88] = 14'd1500;
   assign songFrequencyAmplitudes[1][88] =  8'd65;
   assign songFrequencies        [2][88] = 14'd1480;
   assign songFrequencyAmplitudes[2][88] =  8'd50;
   //--
   assign songFrequencies        [0][89] = 14'd1500;
   assign songFrequencyAmplitudes[0][89] =  8'd63;
   assign songFrequencies        [1][89] = 14'd1513;
   assign songFrequencyAmplitudes[1][89] =  8'd62;
   assign songFrequencies        [2][89] = 14'd1520;
   assign songFrequencyAmplitudes[2][89] =  8'd49;
   //--
   assign songFrequencies        [0][90] = 14'd1513;
   assign songFrequencyAmplitudes[0][90] =  8'd58;
   assign songFrequencies        [1][90] = 14'd1526;
   assign songFrequencyAmplitudes[1][90] =  8'd57;
   assign songFrequencies        [2][90] = 14'd1533;
   assign songFrequencyAmplitudes[2][90] =  8'd50;
   //--
   assign songFrequencies        [0][91] = 14'd1546;
   assign songFrequencyAmplitudes[0][91] =  8'd54;
   assign songFrequencies        [1][91] = 14'd1533;
   assign songFrequencyAmplitudes[1][91] =  8'd53;
   assign songFrequencies        [2][91] = 14'd1526;
   assign songFrequencyAmplitudes[2][91] =  8'd52;
   //--
   assign songFrequencies        [0][92] = 14'd1546;
   assign songFrequencyAmplitudes[0][92] =  8'd59;
   assign songFrequencies        [1][92] = 14'd1560;
   assign songFrequencyAmplitudes[1][92] =  8'd59;
   assign songFrequencies        [2][92] = 14'd1540;
   assign songFrequencyAmplitudes[2][92] =  8'd49;
   //--
   assign songFrequencies        [0][93] = 14'd1560;
   assign songFrequencyAmplitudes[0][93] =  8'd63;
   assign songFrequencies        [1][93] = 14'd1573;
   assign songFrequencyAmplitudes[1][93] =  8'd63;
   assign songFrequencies        [2][93] = 14'd1553;
   assign songFrequencyAmplitudes[2][93] =  8'd49;
   //--
   assign songFrequencies        [0][94] = 14'd1573;
   assign songFrequencyAmplitudes[0][94] =  8'd63;
   assign songFrequencies        [1][94] = 14'd1586;
   assign songFrequencyAmplitudes[1][94] =  8'd63;
   assign songFrequencies        [2][94] = 14'd1566;
   assign songFrequencyAmplitudes[2][94] =  8'd48;
   //--
   assign songFrequencies        [0][95] = 14'd1586;
   assign songFrequencyAmplitudes[0][95] =  8'd60;
   assign songFrequencies        [1][95] = 14'd1600;
   assign songFrequencyAmplitudes[1][95] =  8'd60;
   assign songFrequencies        [2][95] = 14'd1606;
   assign songFrequencyAmplitudes[2][95] =  8'd48;
   //--
   assign songFrequencies        [0][96] = 14'd1600;
   assign songFrequencyAmplitudes[0][96] =  8'd55;
   assign songFrequencies        [1][96] = 14'd1613;
   assign songFrequencyAmplitudes[1][96] =  8'd53;
   assign songFrequencies        [2][96] = 14'd1620;
   assign songFrequencyAmplitudes[2][96] =  8'd50;
   //--
   assign songFrequencies        [0][97] = 14'd1633;
   assign songFrequencyAmplitudes[0][97] =  8'd54;
   assign songFrequencies        [1][97] = 14'd1620;
   assign songFrequencyAmplitudes[1][97] =  8'd54;
   assign songFrequencies        [2][97] = 14'd1613;
   assign songFrequencyAmplitudes[2][97] =  8'd50;
   //--
   assign songFrequencies        [0][98] = 14'd1633;
   assign songFrequencyAmplitudes[0][98] =  8'd59;
   assign songFrequencies        [1][98] = 14'd1646;
   assign songFrequencyAmplitudes[1][98] =  8'd59;
   assign songFrequencies        [2][98] = 14'd1626;
   assign songFrequencyAmplitudes[2][98] =  8'd48;
   //--
   assign songFrequencies        [0][99] = 14'd1646;
   assign songFrequencyAmplitudes[0][99] =  8'd62;
   assign songFrequencies        [1][99] = 14'd1660;
   assign songFrequencyAmplitudes[1][99] =  8'd62;
   assign songFrequencies        [2][99] = 14'd1640;
   assign songFrequencyAmplitudes[2][99] =  8'd47;
   //--
   assign songFrequencies        [0][100] = 14'd1660;
   assign songFrequencyAmplitudes[0][100] =  8'd61;
   assign songFrequencies        [1][100] = 14'd1673;
   assign songFrequencyAmplitudes[1][100] =  8'd61;
   assign songFrequencies        [2][100] = 14'd1653;
   assign songFrequencyAmplitudes[2][100] =  8'd47;
   //--
   assign songFrequencies        [0][101] = 14'd1673;
   assign songFrequencyAmplitudes[0][101] =  8'd57;
   assign songFrequencies        [1][101] = 14'd1686;
   assign songFrequencyAmplitudes[1][101] =  8'd57;
   assign songFrequencies        [2][101] = 14'd1693;
   assign songFrequencyAmplitudes[2][101] =  8'd47;
   //--
   assign songFrequencies        [0][102] = 14'd1686;
   assign songFrequencyAmplitudes[0][102] =  8'd52;
   assign songFrequencies        [1][102] = 14'd1700;
   assign songFrequencyAmplitudes[1][102] =  8'd50;
   assign songFrequencies        [2][102] = 14'd1706;
   assign songFrequencyAmplitudes[2][102] =  8'd50;
   //--
   assign songFrequencies        [0][103] = 14'd1720;
   assign songFrequencyAmplitudes[0][103] =  8'd54;
   assign songFrequencies        [1][103] = 14'd1706;
   assign songFrequencyAmplitudes[1][103] =  8'd54;
   assign songFrequencies        [2][103] = 14'd1700;
   assign songFrequencyAmplitudes[2][103] =  8'd48;
   //--
   assign songFrequencies        [0][104] = 14'd1720;
   assign songFrequencyAmplitudes[0][104] =  8'd59;
   assign songFrequencies        [1][104] = 14'd1733;
   assign songFrequencyAmplitudes[1][104] =  8'd59;
   assign songFrequencies        [2][104] = 14'd1713;
   assign songFrequencyAmplitudes[2][104] =  8'd46;
   //--
   assign songFrequencies        [0][105] = 14'd1733;
   assign songFrequencyAmplitudes[0][105] =  8'd60;
   assign songFrequencies        [1][105] = 14'd1746;
   assign songFrequencyAmplitudes[1][105] =  8'd60;
   assign songFrequencies        [2][105] = 14'd1726;
   assign songFrequencyAmplitudes[2][105] =  8'd46;
   //--
   assign songFrequencies        [0][106] = 14'd1746;
   assign songFrequencyAmplitudes[0][106] =  8'd59;
   assign songFrequencies        [1][106] = 14'd1760;
   assign songFrequencyAmplitudes[1][106] =  8'd58;
   assign songFrequencies        [2][106] = 14'd1766;
   assign songFrequencyAmplitudes[2][106] =  8'd45;
   //--
   assign songFrequencies        [0][107] = 14'd1760;
   assign songFrequencyAmplitudes[0][107] =  8'd54;
   assign songFrequencies        [1][107] = 14'd1773;
   assign songFrequencyAmplitudes[1][107] =  8'd53;
   assign songFrequencies        [2][107] = 14'd1780;
   assign songFrequencyAmplitudes[2][107] =  8'd46;
   //--
   assign songFrequencies        [0][108] = 14'd1793;
   assign songFrequencyAmplitudes[0][108] =  8'd49;
   assign songFrequencies        [1][108] = 14'd1773;
   assign songFrequencyAmplitudes[1][108] =  8'd49;
   assign songFrequencies        [2][108] = 14'd1780;
   assign songFrequencyAmplitudes[2][108] =  8'd48;
   //--
   assign songFrequencies        [0][109] = 14'd1793;
   assign songFrequencyAmplitudes[0][109] =  8'd54;
   assign songFrequencies        [1][109] = 14'd1806;
   assign songFrequencyAmplitudes[1][109] =  8'd54;
   assign songFrequencies        [2][109] = 14'd1786;
   assign songFrequencyAmplitudes[2][109] =  8'd46;
   //--
   assign songFrequencies        [0][110] = 14'd1806;
   assign songFrequencyAmplitudes[0][110] =  8'd58;
   assign songFrequencies        [1][110] = 14'd1820;
   assign songFrequencyAmplitudes[1][110] =  8'd58;
   assign songFrequencies        [2][110] = 14'd1800;
   assign songFrequencyAmplitudes[2][110] =  8'd45;
   //--
   assign songFrequencies        [0][111] = 14'd1820;
   assign songFrequencyAmplitudes[0][111] =  8'd59;
   assign songFrequencies        [1][111] = 14'd1833;
   assign songFrequencyAmplitudes[1][111] =  8'd58;
   assign songFrequencies        [2][111] = 14'd1813;
   assign songFrequencyAmplitudes[2][111] =  8'd45;
   //--
   assign songFrequencies        [0][112] = 14'd1833;
   assign songFrequencyAmplitudes[0][112] =  8'd56;
   assign songFrequencies        [1][112] = 14'd1846;
   assign songFrequencyAmplitudes[1][112] =  8'd56;
   assign songFrequencies        [2][112] = 14'd1853;
   assign songFrequencyAmplitudes[2][112] =  8'd44;
   //--
   assign songFrequencies        [0][113] = 14'd1846;
   assign songFrequencyAmplitudes[0][113] =  8'd51;
   assign songFrequencies        [1][113] = 14'd1860;
   assign songFrequencyAmplitudes[1][113] =  8'd50;
   assign songFrequencies        [2][113] = 14'd1866;
   assign songFrequencyAmplitudes[2][113] =  8'd46;
   //--
   assign songFrequencies        [0][114] = 14'd1880;
   assign songFrequencyAmplitudes[0][114] =  8'd50;
   assign songFrequencies        [1][114] = 14'd1866;
   assign songFrequencyAmplitudes[1][114] =  8'd49;
   assign songFrequencies        [2][114] = 14'd1860;
   assign songFrequencyAmplitudes[2][114] =  8'd47;
   //--
   assign songFrequencies        [0][115] = 14'd1880;
   assign songFrequencyAmplitudes[0][115] =  8'd54;
   assign songFrequencies        [1][115] = 14'd1893;
   assign songFrequencyAmplitudes[1][115] =  8'd54;
   assign songFrequencies        [2][115] = 14'd1873;
   assign songFrequencyAmplitudes[2][115] =  8'd44;
   //--
   assign songFrequencies        [0][116] = 14'd1893;
   assign songFrequencyAmplitudes[0][116] =  8'd57;
   assign songFrequencies        [1][116] = 14'd1906;
   assign songFrequencyAmplitudes[1][116] =  8'd57;
   assign songFrequencies        [2][116] = 14'd1886;
   assign songFrequencyAmplitudes[2][116] =  8'd44;
   //--
   assign songFrequencies        [0][117] = 14'd1906;
   assign songFrequencyAmplitudes[0][117] =  8'd57;
   assign songFrequencies        [1][117] = 14'd1920;
   assign songFrequencyAmplitudes[1][117] =  8'd56;
   assign songFrequencies        [2][117] = 14'd1900;
   assign songFrequencyAmplitudes[2][117] =  8'd43;
   //--
   assign songFrequencies        [0][118] = 14'd1920;
   assign songFrequencyAmplitudes[0][118] =  8'd53;
   assign songFrequencies        [1][118] = 14'd1933;
   assign songFrequencyAmplitudes[1][118] =  8'd53;
   assign songFrequencies        [2][118] = 14'd1940;
   assign songFrequencyAmplitudes[2][118] =  8'd43;
   //--
   assign songFrequencies        [0][119] = 14'd1933;
   assign songFrequencyAmplitudes[0][119] =  8'd48;
   assign songFrequencies        [1][119] = 14'd1946;
   assign songFrequencyAmplitudes[1][119] =  8'd47;
   assign songFrequencies        [2][119] = 14'd1953;
   assign songFrequencyAmplitudes[2][119] =  8'd45;
   //--
   assign songFrequencies        [0][120] = 14'd1966;
   assign songFrequencyAmplitudes[0][120] =  8'd49;
   assign songFrequencies        [1][120] = 14'd1953;
   assign songFrequencyAmplitudes[1][120] =  8'd49;
   assign songFrequencies        [2][120] = 14'd1946;
   assign songFrequencyAmplitudes[2][120] =  8'd44;
   //--
   assign songFrequencies        [0][121] = 14'd1966;
   assign songFrequencyAmplitudes[0][121] =  8'd54;
   assign songFrequencies        [1][121] = 14'd1980;
   assign songFrequencyAmplitudes[1][121] =  8'd53;
   assign songFrequencies        [2][121] = 14'd1960;
   assign songFrequencyAmplitudes[2][121] =  8'd43;
   //--
   assign songFrequencies        [0][122] = 14'd1980;
   assign songFrequencyAmplitudes[0][122] =  8'd56;
   assign songFrequencies        [1][122] = 14'd1993;
   assign songFrequencyAmplitudes[1][122] =  8'd55;
   assign songFrequencies        [2][122] = 14'd1973;
   assign songFrequencyAmplitudes[2][122] =  8'd43;
   //--
   assign songFrequencies        [0][123] = 14'd1993;
   assign songFrequencyAmplitudes[0][123] =  8'd54;
   assign songFrequencies        [1][123] = 14'd2006;
   assign songFrequencyAmplitudes[1][123] =  8'd54;
   assign songFrequencies        [2][123] = 14'd1986;
   assign songFrequencyAmplitudes[2][123] =  8'd42;
   //--
   assign songFrequencies        [0][124] = 14'd2006;
   assign songFrequencyAmplitudes[0][124] =  8'd51;
   assign songFrequencies        [1][124] = 14'd2020;
   assign songFrequencyAmplitudes[1][124] =  8'd50;
   assign songFrequencies        [2][124] = 14'd2026;
   assign songFrequencyAmplitudes[2][124] =  8'd42;
   //--
   assign songFrequencies        [0][125] = 14'd2020;
   assign songFrequencyAmplitudes[0][125] =  8'd46;
   assign songFrequencies        [1][125] = 14'd2040;
   assign songFrequencyAmplitudes[1][125] =  8'd45;
   assign songFrequencies        [2][125] = 14'd2033;
   assign songFrequencyAmplitudes[2][125] =  8'd44;
   //--
   assign songFrequencies        [0][126] = 14'd2053;
   assign songFrequencyAmplitudes[0][126] =  8'd49;
   assign songFrequencies        [1][126] = 14'd2040;
   assign songFrequencyAmplitudes[1][126] =  8'd49;
   assign songFrequencies        [2][126] = 14'd2033;
   assign songFrequencyAmplitudes[2][126] =  8'd43;
   //--
   assign songFrequencies        [0][127] = 14'd2053;
   assign songFrequencyAmplitudes[0][127] =  8'd53;
   assign songFrequencies        [1][127] = 14'd2066;
   assign songFrequencyAmplitudes[1][127] =  8'd53;
   assign songFrequencies        [2][127] = 14'd2046;
   assign songFrequencyAmplitudes[2][127] =  8'd41;
   //--
   assign songFrequencies        [0][128] = 14'd2066;
   assign songFrequencyAmplitudes[0][128] =  8'd54;
   assign songFrequencies        [1][128] = 14'd2080;
   assign songFrequencyAmplitudes[1][128] =  8'd54;
   assign songFrequencies        [2][128] = 14'd2060;
   assign songFrequencyAmplitudes[2][128] =  8'd41;
   //--
   assign songFrequencies        [0][129] = 14'd2080;
   assign songFrequencyAmplitudes[0][129] =  8'd52;
   assign songFrequencies        [1][129] = 14'd2093;
   assign songFrequencyAmplitudes[1][129] =  8'd52;
   assign songFrequencies        [2][129] = 14'd2100;
   assign songFrequencyAmplitudes[2][129] =  8'd41;
   //--
   assign songFrequencies        [0][130] = 14'd2093;
   assign songFrequencyAmplitudes[0][130] =  8'd48;
   assign songFrequencies        [1][130] = 14'd2106;
   assign songFrequencyAmplitudes[1][130] =  8'd47;
   assign songFrequencies        [2][130] = 14'd2113;
   assign songFrequencyAmplitudes[2][130] =  8'd42;
   //--
   assign songFrequencies        [0][131] = 14'd2126;
   assign songFrequencyAmplitudes[0][131] =  8'd45;
   assign songFrequencies        [1][131] = 14'd2113;
   assign songFrequencyAmplitudes[1][131] =  8'd44;
   assign songFrequencies        [2][131] = 14'd2106;
   assign songFrequencyAmplitudes[2][131] =  8'd43;
   //--
   assign songFrequencies        [0][132] = 14'd2126;
   assign songFrequencyAmplitudes[0][132] =  8'd49;
   assign songFrequencies        [1][132] = 14'd2140;
   assign songFrequencyAmplitudes[1][132] =  8'd49;
   assign songFrequencies        [2][132] = 14'd2120;
   assign songFrequencyAmplitudes[2][132] =  8'd41;
   //--
   assign songFrequencies        [0][133] = 14'd2140;
   assign songFrequencyAmplitudes[0][133] =  8'd52;
   assign songFrequencies        [1][133] = 14'd2153;
   assign songFrequencyAmplitudes[1][133] =  8'd52;
   assign songFrequencies        [2][133] = 14'd2133;
   assign songFrequencyAmplitudes[2][133] =  8'd40;
   //--
   assign songFrequencies        [0][134] = 14'd2153;
   assign songFrequencyAmplitudes[0][134] =  8'd52;
   assign songFrequencies        [1][134] = 14'd2166;
   assign songFrequencyAmplitudes[1][134] =  8'd52;
   assign songFrequencies        [2][134] = 14'd2146;
   assign songFrequencyAmplitudes[2][134] =  8'd40;
   //--
   assign songFrequencies        [0][135] = 14'd2166;
   assign songFrequencyAmplitudes[0][135] =  8'd49;
   assign songFrequencies        [1][135] = 14'd2180;
   assign songFrequencyAmplitudes[1][135] =  8'd49;
   assign songFrequencies        [2][135] = 14'd2186;
   assign songFrequencyAmplitudes[2][135] =  8'd39;
   //--
   assign songFrequencies        [0][136] = 14'd2180;
   assign songFrequencyAmplitudes[0][136] =  8'd45;
   assign songFrequencies        [1][136] = 14'd2193;
   assign songFrequencyAmplitudes[1][136] =  8'd44;
   assign songFrequencies        [2][136] = 14'd2200;
   assign songFrequencyAmplitudes[2][136] =  8'd41;
   //--
   assign songFrequencies        [0][137] = 14'd2213;
   assign songFrequencyAmplitudes[0][137] =  8'd45;
   assign songFrequencies        [1][137] = 14'd2200;
   assign songFrequencyAmplitudes[1][137] =  8'd44;
   assign songFrequencies        [2][137] = 14'd2193;
   assign songFrequencyAmplitudes[2][137] =  8'd41;
   //--
   assign songFrequencies        [0][138] = 14'd2213;
   assign songFrequencyAmplitudes[0][138] =  8'd49;
   assign songFrequencies        [1][138] = 14'd2226;
   assign songFrequencyAmplitudes[1][138] =  8'd48;
   assign songFrequencies        [2][138] = 14'd2206;
   assign songFrequencyAmplitudes[2][138] =  8'd39;
   //--
   assign songFrequencies        [0][139] = 14'd2226;
   assign songFrequencyAmplitudes[0][139] =  8'd51;
   assign songFrequencies        [1][139] = 14'd2240;
   assign songFrequencyAmplitudes[1][139] =  8'd51;
   assign songFrequencies        [2][139] = 14'd2220;
   assign songFrequencyAmplitudes[2][139] =  8'd39;
   //--
   assign songFrequencies        [0][140] = 14'd2240;
   assign songFrequencyAmplitudes[0][140] =  8'd50;
   assign songFrequencies        [1][140] = 14'd2253;
   assign songFrequencyAmplitudes[1][140] =  8'd50;
   assign songFrequencies        [2][140] = 14'd2233;
   assign songFrequencyAmplitudes[2][140] =  8'd38;
   //--
   assign songFrequencies        [0][141] = 14'd2253;
   assign songFrequencyAmplitudes[0][141] =  8'd47;
   assign songFrequencies        [1][141] = 14'd2266;
   assign songFrequencyAmplitudes[1][141] =  8'd46;
   assign songFrequencies        [2][141] = 14'd2273;
   assign songFrequencyAmplitudes[2][141] =  8'd38;
   //--
   assign songFrequencies        [0][142] = 14'd2266;
   assign songFrequencyAmplitudes[0][142] =  8'd43;
   assign songFrequencies        [1][142] = 14'd2280;
   assign songFrequencyAmplitudes[1][142] =  8'd41;
   assign songFrequencies        [2][142] = 14'd2286;
   assign songFrequencyAmplitudes[2][142] =  8'd41;
   //--
   assign songFrequencies        [0][143] = 14'd2300;
   assign songFrequencyAmplitudes[0][143] =  8'd44;
   assign songFrequencies        [1][143] = 14'd2286;
   assign songFrequencyAmplitudes[1][143] =  8'd44;
   assign songFrequencies        [2][143] = 14'd2280;
   assign songFrequencyAmplitudes[2][143] =  8'd39;
   //--
   assign songFrequencies        [0][144] = 14'd2300;
   assign songFrequencyAmplitudes[0][144] =  8'd48;
   assign songFrequencies        [1][144] = 14'd2313;
   assign songFrequencyAmplitudes[1][144] =  8'd48;
   assign songFrequencies        [2][144] = 14'd2293;
   assign songFrequencyAmplitudes[2][144] =  8'd38;
   //--
   assign songFrequencies        [0][145] = 14'd2313;
   assign songFrequencyAmplitudes[0][145] =  8'd49;
   assign songFrequencies        [1][145] = 14'd2326;
   assign songFrequencyAmplitudes[1][145] =  8'd49;
   assign songFrequencies        [2][145] = 14'd2306;
   assign songFrequencyAmplitudes[2][145] =  8'd38;
   //--
   assign songFrequencies        [0][146] = 14'd2326;
   assign songFrequencyAmplitudes[0][146] =  8'd48;
   assign songFrequencies        [1][146] = 14'd2340;
   assign songFrequencyAmplitudes[1][146] =  8'd48;
   assign songFrequencies        [2][146] = 14'd2346;
   assign songFrequencyAmplitudes[2][146] =  8'd37;
   //--
   assign songFrequencies        [0][147] = 14'd2340;
   assign songFrequencyAmplitudes[0][147] =  8'd44;
   assign songFrequencies        [1][147] = 14'd2353;
   assign songFrequencyAmplitudes[1][147] =  8'd44;
   assign songFrequencies        [2][147] = 14'd2360;
   assign songFrequencyAmplitudes[2][147] =  8'd38;
   //--
   assign songFrequencies        [0][148] = 14'd2373;
   assign songFrequencyAmplitudes[0][148] =  8'd40;
   assign songFrequencies        [1][148] = 14'd2353;
   assign songFrequencyAmplitudes[1][148] =  8'd40;
   assign songFrequencies        [2][148] = 14'd2360;
   assign songFrequencyAmplitudes[2][148] =  8'd39;
   //--
   assign songFrequencies        [0][149] = 14'd2373;
   assign songFrequencyAmplitudes[0][149] =  8'd44;
   assign songFrequencies        [1][149] = 14'd2386;
   assign songFrequencyAmplitudes[1][149] =  8'd44;
   assign songFrequencies        [2][149] = 14'd2366;
   assign songFrequencyAmplitudes[2][149] =  8'd37;
   //--
   assign songFrequencies        [0][150] = 14'd2386;
   assign songFrequencyAmplitudes[0][150] =  8'd47;
   assign songFrequencies        [1][150] = 14'd2400;
   assign songFrequencyAmplitudes[1][150] =  8'd47;
   assign songFrequencies        [2][150] = 14'd2380;
   assign songFrequencyAmplitudes[2][150] =  8'd37;
   //--
   assign songFrequencies        [0][151] = 14'd2400;
   assign songFrequencyAmplitudes[0][151] =  8'd48;
   assign songFrequencies        [1][151] = 14'd2413;
   assign songFrequencyAmplitudes[1][151] =  8'd47;
   assign songFrequencies        [2][151] = 14'd2393;
   assign songFrequencyAmplitudes[2][151] =  8'd36;
   //--
   assign songFrequencies        [0][152] = 14'd2413;
   assign songFrequencyAmplitudes[0][152] =  8'd45;
   assign songFrequencies        [1][152] = 14'd2426;
   assign songFrequencyAmplitudes[1][152] =  8'd45;
   assign songFrequencies        [2][152] = 14'd2433;
   assign songFrequencyAmplitudes[2][152] =  8'd36;
   //--
   assign songFrequencies        [0][153] = 14'd2426;
   assign songFrequencyAmplitudes[0][153] =  8'd42;
   assign songFrequencies        [1][153] = 14'd2440;
   assign songFrequencyAmplitudes[1][153] =  8'd41;
   assign songFrequencies        [2][153] = 14'd2446;
   assign songFrequencyAmplitudes[2][153] =  8'd37;
   //--
   assign songFrequencies        [0][154] = 14'd2460;
   assign songFrequencyAmplitudes[0][154] =  8'd40;
   assign songFrequencies        [1][154] = 14'd2446;
   assign songFrequencyAmplitudes[1][154] =  8'd40;
   assign songFrequencies        [2][154] = 14'd2440;
   assign songFrequencyAmplitudes[2][154] =  8'd38;
   //--
   assign songFrequencies        [0][155] = 14'd2460;
   assign songFrequencyAmplitudes[0][155] =  8'd44;
   assign songFrequencies        [1][155] = 14'd2473;
   assign songFrequencyAmplitudes[1][155] =  8'd44;
   assign songFrequencies        [2][155] = 14'd2453;
   assign songFrequencyAmplitudes[2][155] =  8'd36;
   //--
   assign songFrequencies        [0][156] = 14'd2473;
   assign songFrequencyAmplitudes[0][156] =  8'd46;
   assign songFrequencies        [1][156] = 14'd2486;
   assign songFrequencyAmplitudes[1][156] =  8'd46;
   assign songFrequencies        [2][156] = 14'd2466;
   assign songFrequencyAmplitudes[2][156] =  8'd35;
   //--
   assign songFrequencies        [0][157] = 14'd2486;
   assign songFrequencyAmplitudes[0][157] =  8'd46;
   assign songFrequencies        [1][157] = 14'd2500;
   assign songFrequencyAmplitudes[1][157] =  8'd45;
   assign songFrequencies        [2][157] = 14'd2480;
   assign songFrequencyAmplitudes[2][157] =  8'd35;
   //--
   assign songFrequencies        [0][158] = 14'd2500;
   assign songFrequencyAmplitudes[0][158] =  8'd43;
   assign songFrequencies        [1][158] = 14'd2513;
   assign songFrequencyAmplitudes[1][158] =  8'd43;
   assign songFrequencies        [2][158] = 14'd2520;
   assign songFrequencyAmplitudes[2][158] =  8'd35;
   //--
   assign songFrequencies        [0][159] = 14'd2513;
   assign songFrequencyAmplitudes[0][159] =  8'd39;
   assign songFrequencies        [1][159] = 14'd2526;
   assign songFrequencyAmplitudes[1][159] =  8'd38;
   assign songFrequencies        [2][159] = 14'd2533;
   assign songFrequencyAmplitudes[2][159] =  8'd36;
   //--
   assign songFrequencies        [0][160] = 14'd2546;
   assign songFrequencyAmplitudes[0][160] =  8'd40;
   assign songFrequencies        [1][160] = 14'd2533;
   assign songFrequencyAmplitudes[1][160] =  8'd39;
   assign songFrequencies        [2][160] = 14'd2526;
   assign songFrequencyAmplitudes[2][160] =  8'd36;
   //--
   assign songFrequencies        [0][161] = 14'd2546;
   assign songFrequencyAmplitudes[0][161] =  8'd43;
   assign songFrequencies        [1][161] = 14'd2560;
   assign songFrequencyAmplitudes[1][161] =  8'd43;
   assign songFrequencies        [2][161] = 14'd2540;
   assign songFrequencyAmplitudes[2][161] =  8'd34;
   //--
   assign songFrequencies        [0][162] = 14'd2560;
   assign songFrequencyAmplitudes[0][162] =  8'd45;
   assign songFrequencies        [1][162] = 14'd2573;
   assign songFrequencyAmplitudes[1][162] =  8'd44;
   assign songFrequencies        [2][162] = 14'd2553;
   assign songFrequencyAmplitudes[2][162] =  8'd34;
   //--
   assign songFrequencies        [0][163] = 14'd2573;
   assign songFrequencyAmplitudes[0][163] =  8'd44;
   assign songFrequencies        [1][163] = 14'd2586;
   assign songFrequencyAmplitudes[1][163] =  8'd43;
   assign songFrequencies        [2][163] = 14'd2566;
   assign songFrequencyAmplitudes[2][163] =  8'd33;
   //--
   assign songFrequencies        [0][164] = 14'd2586;
   assign songFrequencyAmplitudes[0][164] =  8'd40;
   assign songFrequencies        [1][164] = 14'd2600;
   assign songFrequencyAmplitudes[1][164] =  8'd40;
   assign songFrequencies        [2][164] = 14'd2606;
   assign songFrequencyAmplitudes[2][164] =  8'd34;
   //--
   assign songFrequencies        [0][165] = 14'd2600;
   assign songFrequencyAmplitudes[0][165] =  8'd37;
   assign songFrequencies        [1][165] = 14'd2620;
   assign songFrequencyAmplitudes[1][165] =  8'd36;
   assign songFrequencies        [2][165] = 14'd2613;
   assign songFrequencyAmplitudes[2][165] =  8'd35;
   //--
   assign songFrequencies        [0][166] = 14'd2620;
   assign songFrequencyAmplitudes[0][166] =  8'd39;
   assign songFrequencies        [1][166] = 14'd2633;
   assign songFrequencyAmplitudes[1][166] =  8'd39;
   assign songFrequencies        [2][166] = 14'd2613;
   assign songFrequencyAmplitudes[2][166] =  8'd34;
   //--
   assign songFrequencies        [0][167] = 14'd2633;
   assign songFrequencyAmplitudes[0][167] =  8'd42;
   assign songFrequencies        [1][167] = 14'd2646;
   assign songFrequencyAmplitudes[1][167] =  8'd42;
   assign songFrequencies        [2][167] = 14'd2626;
   assign songFrequencyAmplitudes[2][167] =  8'd33;
   //--
   assign songFrequencies        [0][168] = 14'd2646;
   assign songFrequencyAmplitudes[0][168] =  8'd43;
   assign songFrequencies        [1][168] = 14'd2660;
   assign songFrequencyAmplitudes[1][168] =  8'd43;
   assign songFrequencies        [2][168] = 14'd2640;
   assign songFrequencyAmplitudes[2][168] =  8'd33;
   //--
   assign songFrequencies        [0][169] = 14'd2660;
   assign songFrequencyAmplitudes[0][169] =  8'd41;
   assign songFrequencies        [1][169] = 14'd2673;
   assign songFrequencyAmplitudes[1][169] =  8'd41;
   assign songFrequencies        [2][169] = 14'd2680;
   assign songFrequencyAmplitudes[2][169] =  8'd32;
   //--
   assign songFrequencies        [0][170] = 14'd2673;
   assign songFrequencyAmplitudes[0][170] =  8'd38;
   assign songFrequencies        [1][170] = 14'd2686;
   assign songFrequencyAmplitudes[1][170] =  8'd37;
   assign songFrequencies        [2][170] = 14'd2693;
   assign songFrequencyAmplitudes[2][170] =  8'd33;
   //--
   assign songFrequencies        [0][171] = 14'd2706;
   assign songFrequencyAmplitudes[0][171] =  8'd35;
   assign songFrequencies        [1][171] = 14'd2693;
   assign songFrequencyAmplitudes[1][171] =  8'd35;
   assign songFrequencies        [2][171] = 14'd2686;
   assign songFrequencyAmplitudes[2][171] =  8'd34;
   //--
   assign songFrequencies        [0][172] = 14'd2706;
   assign songFrequencyAmplitudes[0][172] =  8'd39;
   assign songFrequencies        [1][172] = 14'd2720;
   assign songFrequencyAmplitudes[1][172] =  8'd39;
   assign songFrequencies        [2][172] = 14'd2700;
   assign songFrequencyAmplitudes[2][172] =  8'd32;
   //--
   assign songFrequencies        [0][173] = 14'd2720;
   assign songFrequencyAmplitudes[0][173] =  8'd41;
   assign songFrequencies        [1][173] = 14'd2733;
   assign songFrequencyAmplitudes[1][173] =  8'd41;
   assign songFrequencies        [2][173] = 14'd2713;
   assign songFrequencyAmplitudes[2][173] =  8'd32;
   //--
   assign songFrequencies        [0][174] = 14'd2733;
   assign songFrequencyAmplitudes[0][174] =  8'd41;
   assign songFrequencies        [1][174] = 14'd2746;
   assign songFrequencyAmplitudes[1][174] =  8'd41;
   assign songFrequencies        [2][174] = 14'd2726;
   assign songFrequencyAmplitudes[2][174] =  8'd32;
   //--
   assign songFrequencies        [0][175] = 14'd2746;
   assign songFrequencyAmplitudes[0][175] =  8'd39;
   assign songFrequencies        [1][175] = 14'd2760;
   assign songFrequencyAmplitudes[1][175] =  8'd39;
   assign songFrequencies        [2][175] = 14'd2766;
   assign songFrequencyAmplitudes[2][175] =  8'd31;
   //--
   assign songFrequencies        [0][176] = 14'd2760;
   assign songFrequencyAmplitudes[0][176] =  8'd36;
   assign songFrequencies        [1][176] = 14'd2773;
   assign songFrequencyAmplitudes[1][176] =  8'd35;
   assign songFrequencies        [2][176] = 14'd2780;
   assign songFrequencyAmplitudes[2][176] =  8'd32;
   //--
   assign songFrequencies        [0][177] = 14'd2793;
   assign songFrequencyAmplitudes[0][177] =  8'd35;
   assign songFrequencies        [1][177] = 14'd2780;
   assign songFrequencyAmplitudes[1][177] =  8'd35;
   assign songFrequencies        [2][177] = 14'd2773;
   assign songFrequencyAmplitudes[2][177] =  8'd32;
   //--
   assign songFrequencies        [0][178] = 14'd2793;
   assign songFrequencyAmplitudes[0][178] =  8'd38;
   assign songFrequencies        [1][178] = 14'd2806;
   assign songFrequencyAmplitudes[1][178] =  8'd38;
   assign songFrequencies        [2][178] = 14'd2786;
   assign songFrequencyAmplitudes[2][178] =  8'd31;
   //--
   assign songFrequencies        [0][179] = 14'd2806;
   assign songFrequencyAmplitudes[0][179] =  8'd40;
   assign songFrequencies        [1][179] = 14'd2820;
   assign songFrequencyAmplitudes[1][179] =  8'd40;
   assign songFrequencies        [2][179] = 14'd2800;
   assign songFrequencyAmplitudes[2][179] =  8'd31;
   //--
   assign songFrequencies        [0][180] = 14'd2820;
   assign songFrequencyAmplitudes[0][180] =  8'd39;
   assign songFrequencies        [1][180] = 14'd2833;
   assign songFrequencyAmplitudes[1][180] =  8'd39;
   assign songFrequencies        [2][180] = 14'd2813;
   assign songFrequencyAmplitudes[2][180] =  8'd30;
   //--
   assign songFrequencies        [0][181] = 14'd2833;
   assign songFrequencyAmplitudes[0][181] =  8'd37;
   assign songFrequencies        [1][181] = 14'd2846;
   assign songFrequencyAmplitudes[1][181] =  8'd36;
   assign songFrequencies        [2][181] = 14'd2853;
   assign songFrequencyAmplitudes[2][181] =  8'd30;
   //--
   assign songFrequencies        [0][182] = 14'd2846;
   assign songFrequencyAmplitudes[0][182] =  8'd33;
   assign songFrequencies        [1][182] = 14'd2860;
   assign songFrequencyAmplitudes[1][182] =  8'd32;
   assign songFrequencies        [2][182] = 14'd2866;
   assign songFrequencyAmplitudes[2][182] =  8'd32;
   //--
   assign songFrequencies        [0][183] = 14'd2880;
   assign songFrequencyAmplitudes[0][183] =  8'd34;
   assign songFrequencies        [1][183] = 14'd2866;
   assign songFrequencyAmplitudes[1][183] =  8'd34;
   assign songFrequencies        [2][183] = 14'd2860;
   assign songFrequencyAmplitudes[2][183] =  8'd31;
   //--
   assign songFrequencies        [0][184] = 14'd2880;
   assign songFrequencyAmplitudes[0][184] =  8'd37;
   assign songFrequencies        [1][184] = 14'd2893;
   assign songFrequencyAmplitudes[1][184] =  8'd37;
   assign songFrequencies        [2][184] = 14'd2873;
   assign songFrequencyAmplitudes[2][184] =  8'd29;
   //--
endmodule
