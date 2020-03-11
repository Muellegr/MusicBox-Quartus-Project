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

module MusicBoxState_PlaySong1 ( 
		input logic clock_50Mhz,
		input logic clock_32Khz,
		input logic clock_1Khz,

		input logic reset_n,
		input logic inputSwitch,
		input logic [4:0] currentState, //This is controlled by MusicBoxStateController.   
		
		output logic [31:0] debugString, //This is used to send any data out of the module for testing purposes.  Follows no format.
		
		//Set to 1 when this stage is complete and is ready to return to DoNothing.
		output logic stateComplete,

		//This is the final output meant to be sent to the DAC.
		output logic [7:0] audioAmplitudeOutput

		);
		reg inputSwitch_q; //Detect change of state
		reg inputSwitch_hasPressed; //allows for switch to go back up high again
	//	assign debugString = {16'b0, milisecondCounter};
		//reg [ 15: 0] counter ;

		//Match with songIndexCount
		
		//--Single channel, faster upload rate.   It should update the frequency every 0.05s * 3 to play the song in 20 seconds.
		wire CLK_60hz ;
		ClockGenerator clockGenerator_60hz (
			.inputClock(clock_50Mhz),
			.reset_n(reset_n),
			.outputClock(CLK_60hz)
		);
			defparam	clockGenerator_60hz.BitsNeeded = 32; //Must be able to count up to InputClockEdgesToCount.  
			defparam	clockGenerator_60hz.InputClockEdgesToCount = 1250000; //




		reg [15:0] songIndexCounter ; //Current index value of the song.  This should always be clamped between 0 and songIndexCount.
	//	reg [9:0] milisecondCounter ; //Counts miliseconds.  Reset when reach songStepSize.

		reg outputActive;
		always_ff @(posedge CLK_60hz ) begin //clock_1Khz negedge reset_n 
			inputSwitch_q <= inputSwitch;
			if (currentState != 5'd2) begin
				stateComplete <= 1'b0;
				songIndexCounter <= 16'd0; 
				outputActive <= 0;
				inputSwitch_hasPressed <= 0;
			end
			else begin
				outputActive <= 1;
				if (songIndexCounter == 1230 -1) begin
					stateComplete <= 1'b1; 
				end
				//If we want to end this early
				else if (inputSwitch_q != inputSwitch && inputSwitch == 1 ) begin
					if (inputSwitch_hasPressed == 1) begin
						stateComplete <= 1'b1; 
					end
					else begin inputSwitch_hasPressed <= 1; end
				end
				//Otherwhys increment to next point
				else begin
					songIndexCounter <= songIndexCounter + 1;
				end

			end //If correct state
		
		end //Clock

	//--FREQUENCY GENERATORS
	// assign audioAmplitudeOutput = (outputActive == 1'b1)? (SignalMultiply255(signalGeneratorOutput[0],currentAmplitude[0] )) + 
	// 													  (SignalMultiply255(signalGeneratorOutput[1],currentAmplitude[1] )) + 
	// 													  (SignalMultiply255(signalGeneratorOutput[2],currentAmplitude[2] ))
	// 													 : 8'd0;s
		assign audioAmplitudeOutput = (outputActive == 1'b1) ? (signalGeneratorOutput[0] + signalGeneratorOutput[1] + signalGeneratorOutput[2] ) : 8'd0;
	SignalGenerator_Triangle signalGenerator_Sine0(
		.CLK_32KHz(clock_32Khz),
		.reset_n( reset_n),
		.inputFrequency(currentFrequency[0]),
		.inputAmplitude(currentAmplitude[0]),
		.outputSample(signalGeneratorOutput[0])
	);
	SignalGenerator_Triangle signalGenerator_Sine1(
		.CLK_32KHz(clock_32Khz),
		.reset_n( reset_n),
		.inputFrequency(currentFrequency[1]),
		.inputAmplitude(currentAmplitude[1]),
		.outputSample(signalGeneratorOutput[1])
	);
	SignalGenerator_Triangle signalGenerator_Sine2(
		.CLK_32KHz(clock_32Khz),
		.reset_n( reset_n),
		.inputFrequency(currentFrequency[2]),
		.inputAmplitude(currentAmplitude[2]),
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
bit [2:0][397:0][13:0] songFrequencies;
bit [2:0][397:0][7:0] songFrequencyAmplitudes;

//-=-=-=-=-SONG DATA-=-=-=-=- 
   assign songFrequencies        [0][0] = 14'd19973;
   assign songFrequencyAmplitudes[0][0] =  8'd0;
   assign songFrequencies        [1][0] = 14'd21060;
   assign songFrequencyAmplitudes[1][0] =  8'd0;
   assign songFrequencies        [2][0] = 14'd21733;
   assign songFrequencyAmplitudes[2][0] =  8'd0;
   //--
   assign songFrequencies        [0][1] = 14'd21733;
   assign songFrequencyAmplitudes[0][1] =  8'd0;
   assign songFrequencies        [1][1] = 14'd21060;
   assign songFrequencyAmplitudes[1][1] =  8'd0;
   assign songFrequencies        [2][1] = 14'd20906;
   assign songFrequencyAmplitudes[2][1] =  8'd0;
   //--
   assign songFrequencies        [0][2] = 14'd21686;
   assign songFrequencyAmplitudes[0][2] =  8'd0;
   assign songFrequencies        [1][2] = 14'd20660;
   assign songFrequencyAmplitudes[1][2] =  8'd0;
   assign songFrequencies        [2][2] = 14'd20940;
   assign songFrequencyAmplitudes[2][2] =  8'd0;
   //--
   assign songFrequencies        [0][3] = 14'd20360;
   assign songFrequencyAmplitudes[0][3] =  8'd0;
   assign songFrequencies        [1][3] = 14'd19100;
   assign songFrequencyAmplitudes[1][3] =  8'd0;
   assign songFrequencies        [2][3] = 14'd21840;
   assign songFrequencyAmplitudes[2][3] =  8'd0;
   //--
   assign songFrequencies        [0][4] = 14'd21920;
   assign songFrequencyAmplitudes[0][4] =  8'd0;
   assign songFrequencies        [1][4] = 14'd20180;
   assign songFrequencyAmplitudes[1][4] =  8'd0;
   assign songFrequencies        [2][4] = 14'd17780;
   assign songFrequencyAmplitudes[2][4] =  8'd0;
   //--
   assign songFrequencies        [0][5] = 14'd20906;
   assign songFrequencyAmplitudes[0][5] =  8'd0;
   assign songFrequencies        [1][5] = 14'd20853;
   assign songFrequencyAmplitudes[1][5] =  8'd0;
   assign songFrequencies        [2][5] = 14'd21846;
   assign songFrequencyAmplitudes[2][5] =  8'd0;
   //--
   assign songFrequencies        [0][6] = 14'd20220;
   assign songFrequencyAmplitudes[0][6] =  8'd0;
   assign songFrequencies        [1][6] = 14'd20900;
   assign songFrequencyAmplitudes[1][6] =  8'd0;
   assign songFrequencies        [2][6] = 14'd22013;
   assign songFrequencyAmplitudes[2][6] =  8'd0;
   //--
   assign songFrequencies        [0][7] = 14'd20853;
   assign songFrequencyAmplitudes[0][7] =  8'd0;
   assign songFrequencies        [1][7] = 14'd19620;
   assign songFrequencyAmplitudes[1][7] =  8'd0;
   assign songFrequencies        [2][7] = 14'd18600;
   assign songFrequencyAmplitudes[2][7] =  8'd0;
   //--
   assign songFrequencies        [0][8] = 14'd20393;
   assign songFrequencyAmplitudes[0][8] =  8'd0;
   assign songFrequencies        [1][8] = 14'd21966;
   assign songFrequencyAmplitudes[1][8] =  8'd0;
   assign songFrequencies        [2][8] = 14'd21766;
   assign songFrequencyAmplitudes[2][8] =  8'd0;
   //--
   assign songFrequencies        [0][9] = 14'd21766;
   assign songFrequencyAmplitudes[0][9] =  8'd0;
   assign songFrequencies        [1][9] = 14'd19613;
   assign songFrequencyAmplitudes[1][9] =  8'd0;
   assign songFrequencies        [2][9] = 14'd19746;
   assign songFrequencyAmplitudes[2][9] =  8'd0;
   //--
   assign songFrequencies        [0][10] = 14'd21060;
   assign songFrequencyAmplitudes[0][10] =  8'd0;
   assign songFrequencies        [1][10] = 14'd21746;
   assign songFrequencyAmplitudes[1][10] =  8'd0;
   assign songFrequencies        [2][10] = 14'd19746;
   assign songFrequencyAmplitudes[2][10] =  8'd0;
   //--
   assign songFrequencies        [0][11] = 14'd20673;
   assign songFrequencyAmplitudes[0][11] =  8'd0;
   assign songFrequencies        [1][11] = 14'd20253;
   assign songFrequencyAmplitudes[1][11] =  8'd0;
   assign songFrequencies        [2][11] = 14'd21486;
   assign songFrequencyAmplitudes[2][11] =  8'd0;
   //--
   assign songFrequencies        [0][12] = 14'd19180;
   assign songFrequencyAmplitudes[0][12] =  8'd0;
   assign songFrequencies        [1][12] = 14'd21933;
   assign songFrequencyAmplitudes[1][12] =  8'd0;
   assign songFrequencies        [2][12] = 14'd21786;
   assign songFrequencyAmplitudes[2][12] =  8'd0;
   //--
   assign songFrequencies        [0][13] = 14'd21140;
   assign songFrequencyAmplitudes[0][13] =  8'd0;
   assign songFrequencies        [1][13] = 14'd21906;
   assign songFrequencyAmplitudes[1][13] =  8'd0;
   assign songFrequencies        [2][13] = 14'd19593;
   assign songFrequencyAmplitudes[2][13] =  8'd0;
   //--
   assign songFrequencies        [0][14] = 14'd266;
   assign songFrequencyAmplitudes[0][14] =  8'd1;
   assign songFrequencies        [1][14] = 14'd260;
   assign songFrequencyAmplitudes[1][14] =  8'd1;
   assign songFrequencies        [2][14] = 14'd273;
   assign songFrequencyAmplitudes[2][14] =  8'd1;
   //--
   assign songFrequencies        [0][15] = 14'd246;
   assign songFrequencyAmplitudes[0][15] =  8'd16;
   assign songFrequencies        [1][15] = 14'd253;
   assign songFrequencyAmplitudes[1][15] =  8'd15;
   assign songFrequencies        [2][15] = 14'd240;
   assign songFrequencyAmplitudes[2][15] =  8'd11;
   //--
   assign songFrequencies        [0][16] = 14'd246;
   assign songFrequencyAmplitudes[0][16] =  8'd27;
   assign songFrequencies        [1][16] = 14'd126;
   assign songFrequencyAmplitudes[1][16] =  8'd20;
   assign songFrequencies        [2][16] = 14'd253;
   assign songFrequencyAmplitudes[2][16] =  8'd17;
   //--
   assign songFrequencies        [0][17] = 14'd246;
   assign songFrequencyAmplitudes[0][17] =  8'd37;
   assign songFrequencies        [1][17] = 14'd126;
   assign songFrequencyAmplitudes[1][17] =  8'd24;
   assign songFrequencies        [2][17] = 14'd120;
   assign songFrequencyAmplitudes[2][17] =  8'd19;
   //--
   assign songFrequencies        [0][18] = 14'd246;
   assign songFrequencyAmplitudes[0][18] =  8'd30;
   assign songFrequencies        [1][18] = 14'd120;
   assign songFrequencyAmplitudes[1][18] =  8'd23;
   assign songFrequencies        [2][18] = 14'd126;
   assign songFrequencyAmplitudes[2][18] =  8'd20;
   //--
   assign songFrequencies        [0][19] = 14'd246;
   assign songFrequencyAmplitudes[0][19] =  8'd25;
   assign songFrequencies        [1][19] = 14'd120;
   assign songFrequencyAmplitudes[1][19] =  8'd21;
   assign songFrequencies        [2][19] = 14'd126;
   assign songFrequencyAmplitudes[2][19] =  8'd19;
   //--
   assign songFrequencies        [0][20] = 14'd246;
   assign songFrequencyAmplitudes[0][20] =  8'd20;
   assign songFrequencies        [1][20] = 14'd126;
   assign songFrequencyAmplitudes[1][20] =  8'd19;
   assign songFrequencies        [2][20] = 14'd120;
   assign songFrequencyAmplitudes[2][20] =  8'd18;
   //--
   assign songFrequencies        [0][21] = 14'd246;
   assign songFrequencyAmplitudes[0][21] =  8'd21;
   assign songFrequencies        [1][21] = 14'd126;
   assign songFrequencyAmplitudes[1][21] =  8'd19;
   assign songFrequencies        [2][21] = 14'd120;
   assign songFrequencyAmplitudes[2][21] =  8'd14;
   //--
   assign songFrequencies        [0][22] = 14'd246;
   assign songFrequencyAmplitudes[0][22] =  8'd20;
   assign songFrequencies        [1][22] = 14'd306;
   assign songFrequencyAmplitudes[1][22] =  8'd19;
   assign songFrequencies        [2][22] = 14'd313;
   assign songFrequencyAmplitudes[2][22] =  8'd19;
   //--
   assign songFrequencies        [0][23] = 14'd313;
   assign songFrequencyAmplitudes[0][23] =  8'd30;
   assign songFrequencies        [1][23] = 14'd306;
   assign songFrequencyAmplitudes[1][23] =  8'd26;
   assign songFrequencies        [2][23] = 14'd153;
   assign songFrequencyAmplitudes[2][23] =  8'd18;
   //--
   assign songFrequencies        [0][24] = 14'd313;
   assign songFrequencyAmplitudes[0][24] =  8'd34;
   assign songFrequencies        [1][24] = 14'd306;
   assign songFrequencyAmplitudes[1][24] =  8'd27;
   assign songFrequencies        [2][24] = 14'd153;
   assign songFrequencyAmplitudes[2][24] =  8'd22;
   //--
   assign songFrequencies        [0][25] = 14'd313;
   assign songFrequencyAmplitudes[0][25] =  8'd37;
   assign songFrequencies        [1][25] = 14'd306;
   assign songFrequencyAmplitudes[1][25] =  8'd25;
   assign songFrequencies        [2][25] = 14'd120;
   assign songFrequencyAmplitudes[2][25] =  8'd19;
   //--
   assign songFrequencies        [0][26] = 14'd313;
   assign songFrequencyAmplitudes[0][26] =  8'd38;
   assign songFrequencies        [1][26] = 14'd120;
   assign songFrequencyAmplitudes[1][26] =  8'd24;
   assign songFrequencies        [2][26] = 14'd246;
   assign songFrequencyAmplitudes[2][26] =  8'd21;
   //--
   assign songFrequencies        [0][27] = 14'd313;
   assign songFrequencyAmplitudes[0][27] =  8'd36;
   assign songFrequencies        [1][27] = 14'd246;
   assign songFrequencyAmplitudes[1][27] =  8'd28;
   assign songFrequencies        [2][27] = 14'd126;
   assign songFrequencyAmplitudes[2][27] =  8'd22;
   //--
   assign songFrequencies        [0][28] = 14'd313;
   assign songFrequencyAmplitudes[0][28] =  8'd33;
   assign songFrequencies        [1][28] = 14'd120;
   assign songFrequencyAmplitudes[1][28] =  8'd25;
   assign songFrequencies        [2][28] = 14'd373;
   assign songFrequencyAmplitudes[2][28] =  8'd21;
   //--
   assign songFrequencies        [0][29] = 14'd373;
   assign songFrequencyAmplitudes[0][29] =  8'd30;
   assign songFrequencies        [1][29] = 14'd313;
   assign songFrequencyAmplitudes[1][29] =  8'd29;
   assign songFrequencies        [2][29] = 14'd186;
   assign songFrequencyAmplitudes[2][29] =  8'd22;
   //--
   assign songFrequencies        [0][30] = 14'd186;
   assign songFrequencyAmplitudes[0][30] =  8'd32;
   assign songFrequencies        [1][30] = 14'd373;
   assign songFrequencyAmplitudes[1][30] =  8'd32;
   assign songFrequencies        [2][30] = 14'd313;
   assign songFrequencyAmplitudes[2][30] =  8'd27;
   //--
   assign songFrequencies        [0][31] = 14'd186;
   assign songFrequencyAmplitudes[0][31] =  8'd28;
   assign songFrequencies        [1][31] = 14'd366;
   assign songFrequencyAmplitudes[1][31] =  8'd27;
   assign songFrequencies        [2][31] = 14'd373;
   assign songFrequencyAmplitudes[2][31] =  8'd27;
   //--
   assign songFrequencies        [0][32] = 14'd366;
   assign songFrequencyAmplitudes[0][32] =  8'd30;
   assign songFrequencies        [1][32] = 14'd186;
   assign songFrequencyAmplitudes[1][32] =  8'd26;
   assign songFrequencies        [2][32] = 14'd313;
   assign songFrequencyAmplitudes[2][32] =  8'd25;
   //--
   assign songFrequencies        [0][33] = 14'd366;
   assign songFrequencyAmplitudes[0][33] =  8'd28;
   assign songFrequencies        [1][33] = 14'd313;
   assign songFrequencyAmplitudes[1][33] =  8'd25;
   assign songFrequencies        [2][33] = 14'd186;
   assign songFrequencyAmplitudes[2][33] =  8'd24;
   //--
   assign songFrequencies        [0][34] = 14'd366;
   assign songFrequencyAmplitudes[0][34] =  8'd26;
   assign songFrequencies        [1][34] = 14'd313;
   assign songFrequencyAmplitudes[1][34] =  8'd24;
   assign songFrequencies        [2][34] = 14'd186;
   assign songFrequencyAmplitudes[2][34] =  8'd23;
   //--
   assign songFrequencies        [0][35] = 14'd313;
   assign songFrequencyAmplitudes[0][35] =  8'd24;
   assign songFrequencies        [1][35] = 14'd366;
   assign songFrequencyAmplitudes[1][35] =  8'd24;
   assign songFrequencies        [2][35] = 14'd186;
   assign songFrequencyAmplitudes[2][35] =  8'd24;
   //--
   assign songFrequencies        [0][36] = 14'd186;
   assign songFrequencyAmplitudes[0][36] =  8'd25;
   assign songFrequencies        [1][36] = 14'd313;
   assign songFrequencyAmplitudes[1][36] =  8'd23;
   assign songFrequencies        [2][36] = 14'd366;
   assign songFrequencyAmplitudes[2][36] =  8'd21;
   //--
   assign songFrequencies        [0][37] = 14'd186;
   assign songFrequencyAmplitudes[0][37] =  8'd27;
   assign songFrequencies        [1][37] = 14'd313;
   assign songFrequencyAmplitudes[1][37] =  8'd21;
   assign songFrequencies        [2][37] = 14'd366;
   assign songFrequencyAmplitudes[2][37] =  8'd17;
   //--
   assign songFrequencies        [0][38] = 14'd180;
   assign songFrequencyAmplitudes[0][38] =  8'd24;
   assign songFrequencies        [1][38] = 14'd313;
   assign songFrequencyAmplitudes[1][38] =  8'd21;
   assign songFrequencies        [2][38] = 14'd186;
   assign songFrequencyAmplitudes[2][38] =  8'd21;
   //--
   assign songFrequencies        [0][39] = 14'd186;
   assign songFrequencyAmplitudes[0][39] =  8'd33;
   assign songFrequencies        [1][39] = 14'd180;
   assign songFrequencyAmplitudes[1][39] =  8'd24;
   assign songFrequencies        [2][39] = 14'd313;
   assign songFrequencyAmplitudes[2][39] =  8'd18;
   //--
   assign songFrequencies        [0][40] = 14'd186;
   assign songFrequencyAmplitudes[0][40] =  8'd49;
   assign songFrequencies        [1][40] = 14'd373;
   assign songFrequencyAmplitudes[1][40] =  8'd18;
   assign songFrequencies        [2][40] = 14'd180;
   assign songFrequencyAmplitudes[2][40] =  8'd17;
   //--
   assign songFrequencies        [0][41] = 14'd186;
   assign songFrequencyAmplitudes[0][41] =  8'd49;
   assign songFrequencies        [1][41] = 14'd180;
   assign songFrequencyAmplitudes[1][41] =  8'd21;
   assign songFrequencies        [2][41] = 14'd366;
   assign songFrequencyAmplitudes[2][41] =  8'd20;
   //--
   assign songFrequencies        [0][42] = 14'd186;
   assign songFrequencyAmplitudes[0][42] =  8'd48;
   assign songFrequencies        [1][42] = 14'd366;
   assign songFrequencyAmplitudes[1][42] =  8'd21;
   assign songFrequencies        [2][42] = 14'd180;
   assign songFrequencyAmplitudes[2][42] =  8'd19;
   //--
   assign songFrequencies        [0][43] = 14'd186;
   assign songFrequencyAmplitudes[0][43] =  8'd46;
   assign songFrequencies        [1][43] = 14'd246;
   assign songFrequencyAmplitudes[1][43] =  8'd21;
   assign songFrequencies        [2][43] = 14'd180;
   assign songFrequencyAmplitudes[2][43] =  8'd19;
   //--
   assign songFrequencies        [0][44] = 14'd186;
   assign songFrequencyAmplitudes[0][44] =  8'd44;
   assign songFrequencies        [1][44] = 14'd246;
   assign songFrequencyAmplitudes[1][44] =  8'd22;
   assign songFrequencies        [2][44] = 14'd493;
   assign songFrequencyAmplitudes[2][44] =  8'd21;
   //--
   assign songFrequencies        [0][45] = 14'd186;
   assign songFrequencyAmplitudes[0][45] =  8'd44;
   assign songFrequencies        [1][45] = 14'd246;
   assign songFrequencyAmplitudes[1][45] =  8'd22;
   assign songFrequencies        [2][45] = 14'd493;
   assign songFrequencyAmplitudes[2][45] =  8'd20;
   //--
   assign songFrequencies        [0][46] = 14'd186;
   assign songFrequencyAmplitudes[0][46] =  8'd43;
   assign songFrequencies        [1][46] = 14'd180;
   assign songFrequencyAmplitudes[1][46] =  8'd22;
   assign songFrequencies        [2][46] = 14'd246;
   assign songFrequencyAmplitudes[2][46] =  8'd22;
   //--
   assign songFrequencies        [0][47] = 14'd186;
   assign songFrequencyAmplitudes[0][47] =  8'd43;
   assign songFrequencies        [1][47] = 14'd246;
   assign songFrequencyAmplitudes[1][47] =  8'd23;
   assign songFrequencies        [2][47] = 14'd180;
   assign songFrequencyAmplitudes[2][47] =  8'd21;
   //--
   assign songFrequencies        [0][48] = 14'd186;
   assign songFrequencyAmplitudes[0][48] =  8'd41;
   assign songFrequencies        [1][48] = 14'd246;
   assign songFrequencyAmplitudes[1][48] =  8'd24;
   assign songFrequencies        [2][48] = 14'd180;
   assign songFrequencyAmplitudes[2][48] =  8'd20;
   //--
   assign songFrequencies        [0][49] = 14'd186;
   assign songFrequencyAmplitudes[0][49] =  8'd38;
   assign songFrequencies        [1][49] = 14'd246;
   assign songFrequencyAmplitudes[1][49] =  8'd21;
   assign songFrequencies        [2][49] = 14'd180;
   assign songFrequencyAmplitudes[2][49] =  8'd19;
   //--
   assign songFrequencies        [0][50] = 14'd186;
   assign songFrequencyAmplitudes[0][50] =  8'd36;
   assign songFrequencies        [1][50] = 14'd180;
   assign songFrequencyAmplitudes[1][50] =  8'd19;
   assign songFrequencies        [2][50] = 14'd246;
   assign songFrequencyAmplitudes[2][50] =  8'd17;
   //--
   assign songFrequencies        [0][51] = 14'd186;
   assign songFrequencyAmplitudes[0][51] =  8'd35;
   assign songFrequencies        [1][51] = 14'd180;
   assign songFrequencyAmplitudes[1][51] =  8'd18;
   assign songFrequencies        [2][51] = 14'd493;
   assign songFrequencyAmplitudes[2][51] =  8'd10;
   //--
   assign songFrequencies        [0][52] = 14'd186;
   assign songFrequencyAmplitudes[0][52] =  8'd35;
   assign songFrequencies        [1][52] = 14'd180;
   assign songFrequencyAmplitudes[1][52] =  8'd16;
   assign songFrequencies        [2][52] = 14'd253;
   assign songFrequencyAmplitudes[2][52] =  8'd14;
   //--
   assign songFrequencies        [0][53] = 14'd186;
   assign songFrequencyAmplitudes[0][53] =  8'd34;
   assign songFrequencies        [1][53] = 14'd180;
   assign songFrequencyAmplitudes[1][53] =  8'd18;
   assign songFrequencies        [2][53] = 14'd246;
   assign songFrequencyAmplitudes[2][53] =  8'd13;
   //--
   assign songFrequencies        [0][54] = 14'd186;
   assign songFrequencyAmplitudes[0][54] =  8'd34;
   assign songFrequencies        [1][54] = 14'd246;
   assign songFrequencyAmplitudes[1][54] =  8'd23;
   assign songFrequencies        [2][54] = 14'd180;
   assign songFrequencyAmplitudes[2][54] =  8'd17;
   //--
   assign songFrequencies        [0][55] = 14'd246;
   assign songFrequencyAmplitudes[0][55] =  8'd32;
   assign songFrequencies        [1][55] = 14'd186;
   assign songFrequencyAmplitudes[1][55] =  8'd31;
   assign songFrequencies        [2][55] = 14'd126;
   assign songFrequencyAmplitudes[2][55] =  8'd17;
   //--
   assign songFrequencies        [0][56] = 14'd246;
   assign songFrequencyAmplitudes[0][56] =  8'd40;
   assign songFrequencies        [1][56] = 14'd186;
   assign songFrequencyAmplitudes[1][56] =  8'd24;
   assign songFrequencies        [2][56] = 14'd126;
   assign songFrequencyAmplitudes[2][56] =  8'd21;
   //--
   assign songFrequencies        [0][57] = 14'd246;
   assign songFrequencyAmplitudes[0][57] =  8'd42;
   assign songFrequencies        [1][57] = 14'd126;
   assign songFrequencyAmplitudes[1][57] =  8'd21;
   assign songFrequencies        [2][57] = 14'd120;
   assign songFrequencyAmplitudes[2][57] =  8'd19;
   //--
   assign songFrequencies        [0][58] = 14'd246;
   assign songFrequencyAmplitudes[0][58] =  8'd37;
   assign songFrequencies        [1][58] = 14'd120;
   assign songFrequencyAmplitudes[1][58] =  8'd20;
   assign songFrequencies        [2][58] = 14'd126;
   assign songFrequencyAmplitudes[2][58] =  8'd20;
   //--
   assign songFrequencies        [0][59] = 14'd246;
   assign songFrequencyAmplitudes[0][59] =  8'd30;
   assign songFrequencies        [1][59] = 14'd120;
   assign songFrequencyAmplitudes[1][59] =  8'd20;
   assign songFrequencies        [2][59] = 14'd126;
   assign songFrequencyAmplitudes[2][59] =  8'd19;
   //--
   assign songFrequencies        [0][60] = 14'd246;
   assign songFrequencyAmplitudes[0][60] =  8'd25;
   assign songFrequencies        [1][60] = 14'd126;
   assign songFrequencyAmplitudes[1][60] =  8'd19;
   assign songFrequencies        [2][60] = 14'd120;
   assign songFrequencyAmplitudes[2][60] =  8'd16;
   //--
   assign songFrequencies        [0][61] = 14'd246;
   assign songFrequencyAmplitudes[0][61] =  8'd21;
   assign songFrequencies        [1][61] = 14'd126;
   assign songFrequencyAmplitudes[1][61] =  8'd18;
   assign songFrequencies        [2][61] = 14'd120;
   assign songFrequencyAmplitudes[2][61] =  8'd14;
   //--
   assign songFrequencies        [0][62] = 14'd166;
   assign songFrequencyAmplitudes[0][62] =  8'd21;
   assign songFrequencies        [1][62] = 14'd326;
   assign songFrequencyAmplitudes[1][62] =  8'd19;
   assign songFrequencies        [2][62] = 14'd246;
   assign songFrequencyAmplitudes[2][62] =  8'd17;
   //--
   assign songFrequencies        [0][63] = 14'd166;
   assign songFrequencyAmplitudes[0][63] =  8'd27;
   assign songFrequencies        [1][63] = 14'd326;
   assign songFrequencyAmplitudes[1][63] =  8'd25;
   assign songFrequencies        [2][63] = 14'd126;
   assign songFrequencyAmplitudes[2][63] =  8'd14;
   //--
   assign songFrequencies        [0][64] = 14'd166;
   assign songFrequencyAmplitudes[0][64] =  8'd23;
   assign songFrequencies        [1][64] = 14'd326;
   assign songFrequencyAmplitudes[1][64] =  8'd22;
   assign songFrequencies        [2][64] = 14'd246;
   assign songFrequencyAmplitudes[2][64] =  8'd16;
   //--
   assign songFrequencies        [0][65] = 14'd246;
   assign songFrequencyAmplitudes[0][65] =  8'd26;
   assign songFrequencies        [1][65] = 14'd166;
   assign songFrequencyAmplitudes[1][65] =  8'd21;
   assign songFrequencies        [2][65] = 14'd253;
   assign songFrequencyAmplitudes[2][65] =  8'd18;
   //--
   assign songFrequencies        [0][66] = 14'd246;
   assign songFrequencyAmplitudes[0][66] =  8'd35;
   assign songFrequencies        [1][66] = 14'd166;
   assign songFrequencyAmplitudes[1][66] =  8'd24;
   assign songFrequencies        [2][66] = 14'd120;
   assign songFrequencyAmplitudes[2][66] =  8'd20;
   //--
   assign songFrequencies        [0][67] = 14'd246;
   assign songFrequencyAmplitudes[0][67] =  8'd35;
   assign songFrequencies        [1][67] = 14'd166;
   assign songFrequencyAmplitudes[1][67] =  8'd27;
   assign songFrequencies        [2][67] = 14'd120;
   assign songFrequencyAmplitudes[2][67] =  8'd20;
   //--
   assign songFrequencies        [0][68] = 14'd166;
   assign songFrequencyAmplitudes[0][68] =  8'd29;
   assign songFrequencies        [1][68] = 14'd246;
   assign songFrequencyAmplitudes[1][68] =  8'd29;
   assign songFrequencies        [2][68] = 14'd413;
   assign songFrequencyAmplitudes[2][68] =  8'd21;
   //--
   assign songFrequencies        [0][69] = 14'd413;
   assign songFrequencyAmplitudes[0][69] =  8'd41;
   assign songFrequencies        [1][69] = 14'd420;
   assign songFrequencyAmplitudes[1][69] =  8'd30;
   assign songFrequencies        [2][69] = 14'd166;
   assign songFrequencyAmplitudes[2][69] =  8'd26;
   //--
   assign songFrequencies        [0][70] = 14'd413;
   assign songFrequencyAmplitudes[0][70] =  8'd52;
   assign songFrequencies        [1][70] = 14'd166;
   assign songFrequencyAmplitudes[1][70] =  8'd24;
   assign songFrequencies        [2][70] = 14'd420;
   assign songFrequencyAmplitudes[2][70] =  8'd24;
   //--
   assign songFrequencies        [0][71] = 14'd413;
   assign songFrequencyAmplitudes[0][71] =  8'd47;
   assign songFrequencies        [1][71] = 14'd206;
   assign songFrequencyAmplitudes[1][71] =  8'd23;
   assign songFrequencies        [2][71] = 14'd166;
   assign songFrequencyAmplitudes[2][71] =  8'd23;
   //--
   assign songFrequencies        [0][72] = 14'd413;
   assign songFrequencyAmplitudes[0][72] =  8'd34;
   assign songFrequencies        [1][72] = 14'd166;
   assign songFrequencyAmplitudes[1][72] =  8'd23;
   assign songFrequencies        [2][72] = 14'd206;
   assign songFrequencyAmplitudes[2][72] =  8'd22;
   //--
   assign songFrequencies        [0][73] = 14'd413;
   assign songFrequencyAmplitudes[0][73] =  8'd30;
   assign songFrequencies        [1][73] = 14'd206;
   assign songFrequencyAmplitudes[1][73] =  8'd23;
   assign songFrequencies        [2][73] = 14'd166;
   assign songFrequencyAmplitudes[2][73] =  8'd22;
   //--
   assign songFrequencies        [0][74] = 14'd413;
   assign songFrequencyAmplitudes[0][74] =  8'd28;
   assign songFrequencies        [1][74] = 14'd206;
   assign songFrequencyAmplitudes[1][74] =  8'd21;
   assign songFrequencies        [2][74] = 14'd166;
   assign songFrequencyAmplitudes[2][74] =  8'd19;
   //--
   assign songFrequencies        [0][75] = 14'd413;
   assign songFrequencyAmplitudes[0][75] =  8'd26;
   assign songFrequencies        [1][75] = 14'd206;
   assign songFrequencyAmplitudes[1][75] =  8'd20;
   assign songFrequencies        [2][75] = 14'd166;
   assign songFrequencyAmplitudes[2][75] =  8'd18;
   //--
   assign songFrequencies        [0][76] = 14'd413;
   assign songFrequencyAmplitudes[0][76] =  8'd24;
   assign songFrequencies        [1][76] = 14'd206;
   assign songFrequencyAmplitudes[1][76] =  8'd19;
   assign songFrequencies        [2][76] = 14'd246;
   assign songFrequencyAmplitudes[2][76] =  8'd18;
   //--
   assign songFrequencies        [0][77] = 14'd413;
   assign songFrequencyAmplitudes[0][77] =  8'd23;
   assign songFrequencies        [1][77] = 14'd206;
   assign songFrequencyAmplitudes[1][77] =  8'd22;
   assign songFrequencies        [2][77] = 14'd246;
   assign songFrequencyAmplitudes[2][77] =  8'd18;
   //--
   assign songFrequencies        [0][78] = 14'd413;
   assign songFrequencyAmplitudes[0][78] =  8'd33;
   assign songFrequencies        [1][78] = 14'd206;
   assign songFrequencyAmplitudes[1][78] =  8'd30;
   assign songFrequencies        [2][78] = 14'd420;
   assign songFrequencyAmplitudes[2][78] =  8'd20;
   //--
   assign songFrequencies        [0][79] = 14'd413;
   assign songFrequencyAmplitudes[0][79] =  8'd47;
   assign songFrequencies        [1][79] = 14'd206;
   assign songFrequencyAmplitudes[1][79] =  8'd37;
   assign songFrequencies        [2][79] = 14'd420;
   assign songFrequencyAmplitudes[2][79] =  8'd25;
   //--
   assign songFrequencies        [0][80] = 14'd413;
   assign songFrequencyAmplitudes[0][80] =  8'd52;
   assign songFrequencies        [1][80] = 14'd206;
   assign songFrequencyAmplitudes[1][80] =  8'd42;
   assign songFrequencies        [2][80] = 14'd420;
   assign songFrequencyAmplitudes[2][80] =  8'd20;
   //--
   assign songFrequencies        [0][81] = 14'd413;
   assign songFrequencyAmplitudes[0][81] =  8'd44;
   assign songFrequencies        [1][81] = 14'd206;
   assign songFrequencyAmplitudes[1][81] =  8'd42;
   assign songFrequencies        [2][81] = 14'd420;
   assign songFrequencyAmplitudes[2][81] =  8'd16;
   //--
   assign songFrequencies        [0][82] = 14'd206;
   assign songFrequencyAmplitudes[0][82] =  8'd41;
   assign songFrequencies        [1][82] = 14'd413;
   assign songFrequencyAmplitudes[1][82] =  8'd33;
   assign songFrequencies        [2][82] = 14'd246;
   assign songFrequencyAmplitudes[2][82] =  8'd21;
   //--
   assign songFrequencies        [0][83] = 14'd206;
   assign songFrequencyAmplitudes[0][83] =  8'd40;
   assign songFrequencies        [1][83] = 14'd413;
   assign songFrequencyAmplitudes[1][83] =  8'd28;
   assign songFrequencies        [2][83] = 14'd246;
   assign songFrequencyAmplitudes[2][83] =  8'd27;
   //--
   assign songFrequencies        [0][84] = 14'd206;
   assign songFrequencyAmplitudes[0][84] =  8'd37;
   assign songFrequencies        [1][84] = 14'd246;
   assign songFrequencyAmplitudes[1][84] =  8'd28;
   assign songFrequencies        [2][84] = 14'd413;
   assign songFrequencyAmplitudes[2][84] =  8'd27;
   //--
   assign songFrequencies        [0][85] = 14'd206;
   assign songFrequencyAmplitudes[0][85] =  8'd36;
   assign songFrequencies        [1][85] = 14'd246;
   assign songFrequencyAmplitudes[1][85] =  8'd29;
   assign songFrequencies        [2][85] = 14'd413;
   assign songFrequencyAmplitudes[2][85] =  8'd25;
   //--
   assign songFrequencies        [0][86] = 14'd206;
   assign songFrequencyAmplitudes[0][86] =  8'd33;
   assign songFrequencies        [1][86] = 14'd246;
   assign songFrequencyAmplitudes[1][86] =  8'd30;
   assign songFrequencies        [2][86] = 14'd413;
   assign songFrequencyAmplitudes[2][86] =  8'd22;
   //--
   assign songFrequencies        [0][87] = 14'd206;
   assign songFrequencyAmplitudes[0][87] =  8'd33;
   assign songFrequencies        [1][87] = 14'd246;
   assign songFrequencyAmplitudes[1][87] =  8'd30;
   assign songFrequencies        [2][87] = 14'd493;
   assign songFrequencyAmplitudes[2][87] =  8'd19;
   //--
   assign songFrequencies        [0][88] = 14'd206;
   assign songFrequencyAmplitudes[0][88] =  8'd33;
   assign songFrequencies        [1][88] = 14'd246;
   assign songFrequencyAmplitudes[1][88] =  8'd29;
   assign songFrequencies        [2][88] = 14'd493;
   assign songFrequencyAmplitudes[2][88] =  8'd16;
   //--
   assign songFrequencies        [0][89] = 14'd206;
   assign songFrequencyAmplitudes[0][89] =  8'd32;
   assign songFrequencies        [1][89] = 14'd246;
   assign songFrequencyAmplitudes[1][89] =  8'd25;
   assign songFrequencies        [2][89] = 14'd493;
   assign songFrequencyAmplitudes[2][89] =  8'd15;
   //--
   assign songFrequencies        [0][90] = 14'd206;
   assign songFrequencyAmplitudes[0][90] =  8'd30;
   assign songFrequencies        [1][90] = 14'd246;
   assign songFrequencyAmplitudes[1][90] =  8'd19;
   assign songFrequencies        [2][90] = 14'd493;
   assign songFrequencyAmplitudes[2][90] =  8'd15;
   //--
   assign songFrequencies        [0][91] = 14'd206;
   assign songFrequencyAmplitudes[0][91] =  8'd29;
   assign songFrequencies        [1][91] = 14'd493;
   assign songFrequencyAmplitudes[1][91] =  8'd15;
   assign songFrequencies        [2][91] = 14'd246;
   assign songFrequencyAmplitudes[2][91] =  8'd14;
   //--
   assign songFrequencies        [0][92] = 14'd206;
   assign songFrequencyAmplitudes[0][92] =  8'd28;
   assign songFrequencies        [1][92] = 14'd493;
   assign songFrequencyAmplitudes[1][92] =  8'd18;
   assign songFrequencies        [2][92] = 14'd246;
   assign songFrequencyAmplitudes[2][92] =  8'd14;
   //--
   assign songFrequencies        [0][93] = 14'd206;
   assign songFrequencyAmplitudes[0][93] =  8'd28;
   assign songFrequencies        [1][93] = 14'd493;
   assign songFrequencyAmplitudes[1][93] =  8'd21;
   assign songFrequencies        [2][93] = 14'd246;
   assign songFrequencyAmplitudes[2][93] =  8'd16;
   //--
   assign songFrequencies        [0][94] = 14'd246;
   assign songFrequencyAmplitudes[0][94] =  8'd26;
   assign songFrequencies        [1][94] = 14'd206;
   assign songFrequencyAmplitudes[1][94] =  8'd25;
   assign songFrequencies        [2][94] = 14'd493;
   assign songFrequencyAmplitudes[2][94] =  8'd19;
   //--
   assign songFrequencies        [0][95] = 14'd246;
   assign songFrequencyAmplitudes[0][95] =  8'd32;
   assign songFrequencies        [1][95] = 14'd126;
   assign songFrequencyAmplitudes[1][95] =  8'd21;
   assign songFrequencies        [2][95] = 14'd206;
   assign songFrequencyAmplitudes[2][95] =  8'd20;
   //--
   assign songFrequencies        [0][96] = 14'd246;
   assign songFrequencyAmplitudes[0][96] =  8'd39;
   assign songFrequencies        [1][96] = 14'd126;
   assign songFrequencyAmplitudes[1][96] =  8'd23;
   assign songFrequencies        [2][96] = 14'd120;
   assign songFrequencyAmplitudes[2][96] =  8'd19;
   //--
   assign songFrequencies        [0][97] = 14'd246;
   assign songFrequencyAmplitudes[0][97] =  8'd34;
   assign songFrequencies        [1][97] = 14'd120;
   assign songFrequencyAmplitudes[1][97] =  8'd22;
   assign songFrequencies        [2][97] = 14'd126;
   assign songFrequencyAmplitudes[2][97] =  8'd20;
   //--
   assign songFrequencies        [0][98] = 14'd246;
   assign songFrequencyAmplitudes[0][98] =  8'd29;
   assign songFrequencies        [1][98] = 14'd120;
   assign songFrequencyAmplitudes[1][98] =  8'd20;
   assign songFrequencies        [2][98] = 14'd126;
   assign songFrequencyAmplitudes[2][98] =  8'd20;
   //--
   assign songFrequencies        [0][99] = 14'd246;
   assign songFrequencyAmplitudes[0][99] =  8'd23;
   assign songFrequencies        [1][99] = 14'd126;
   assign songFrequencyAmplitudes[1][99] =  8'd20;
   assign songFrequencies        [2][99] = 14'd120;
   assign songFrequencyAmplitudes[2][99] =  8'd18;
   //--
   assign songFrequencies        [0][100] = 14'd246;
   assign songFrequencyAmplitudes[0][100] =  8'd20;
   assign songFrequencies        [1][100] = 14'd120;
   assign songFrequencyAmplitudes[1][100] =  8'd17;
   assign songFrequencies        [2][100] = 14'd126;
   assign songFrequencyAmplitudes[2][100] =  8'd17;
   //--
   assign songFrequencies        [0][101] = 14'd313;
   assign songFrequencyAmplitudes[0][101] =  8'd17;
   assign songFrequencies        [1][101] = 14'd306;
   assign songFrequencyAmplitudes[1][101] =  8'd17;
   assign songFrequencies        [2][101] = 14'd246;
   assign songFrequencyAmplitudes[2][101] =  8'd16;
   //--
   assign songFrequencies        [0][102] = 14'd313;
   assign songFrequencyAmplitudes[0][102] =  8'd27;
   assign songFrequencies        [1][102] = 14'd306;
   assign songFrequencyAmplitudes[1][102] =  8'd27;
   assign songFrequencies        [2][102] = 14'd153;
   assign songFrequencyAmplitudes[2][102] =  8'd18;
   //--
   assign songFrequencies        [0][103] = 14'd313;
   assign songFrequencyAmplitudes[0][103] =  8'd36;
   assign songFrequencies        [1][103] = 14'd306;
   assign songFrequencyAmplitudes[1][103] =  8'd25;
   assign songFrequencies        [2][103] = 14'd153;
   assign songFrequencyAmplitudes[2][103] =  8'd22;
   //--
   assign songFrequencies        [0][104] = 14'd313;
   assign songFrequencyAmplitudes[0][104] =  8'd39;
   assign songFrequencies        [1][104] = 14'd126;
   assign songFrequencyAmplitudes[1][104] =  8'd24;
   assign songFrequencies        [2][104] = 14'd306;
   assign songFrequencyAmplitudes[2][104] =  8'd23;
   //--
   assign songFrequencies        [0][105] = 14'd313;
   assign songFrequencyAmplitudes[0][105] =  8'd37;
   assign songFrequencies        [1][105] = 14'd126;
   assign songFrequencyAmplitudes[1][105] =  8'd29;
   assign songFrequencies        [2][105] = 14'd246;
   assign songFrequencyAmplitudes[2][105] =  8'd26;
   //--
   assign songFrequencies        [0][106] = 14'd313;
   assign songFrequencyAmplitudes[0][106] =  8'd38;
   assign songFrequencies        [1][106] = 14'd246;
   assign songFrequencyAmplitudes[1][106] =  8'd33;
   assign songFrequencies        [2][106] = 14'd126;
   assign songFrequencyAmplitudes[2][106] =  8'd29;
   //--
   assign songFrequencies        [0][107] = 14'd313;
   assign songFrequencyAmplitudes[0][107] =  8'd34;
   assign songFrequencies        [1][107] = 14'd120;
   assign songFrequencyAmplitudes[1][107] =  8'd28;
   assign songFrequencies        [2][107] = 14'd246;
   assign songFrequencyAmplitudes[2][107] =  8'd23;
   //--
   assign songFrequencies        [0][108] = 14'd313;
   assign songFrequencyAmplitudes[0][108] =  8'd30;
   assign songFrequencies        [1][108] = 14'd120;
   assign songFrequencyAmplitudes[1][108] =  8'd25;
   assign songFrequencies        [2][108] = 14'd126;
   assign songFrequencyAmplitudes[2][108] =  8'd23;
   //--
   assign songFrequencies        [0][109] = 14'd186;
   assign songFrequencyAmplitudes[0][109] =  8'd31;
   assign songFrequencies        [1][109] = 14'd313;
   assign songFrequencyAmplitudes[1][109] =  8'd28;
   assign songFrequencies        [2][109] = 14'd373;
   assign songFrequencyAmplitudes[2][109] =  8'd27;
   //--
   assign songFrequencies        [0][110] = 14'd186;
   assign songFrequencyAmplitudes[0][110] =  8'd32;
   assign songFrequencies        [1][110] = 14'd366;
   assign songFrequencyAmplitudes[1][110] =  8'd26;
   assign songFrequencies        [2][110] = 14'd373;
   assign songFrequencyAmplitudes[2][110] =  8'd25;
   //--
   assign songFrequencies        [0][111] = 14'd366;
   assign songFrequencyAmplitudes[0][111] =  8'd28;
   assign songFrequencies        [1][111] = 14'd186;
   assign songFrequencyAmplitudes[1][111] =  8'd27;
   assign songFrequencies        [2][111] = 14'd313;
   assign songFrequencyAmplitudes[2][111] =  8'd24;
   //--
   assign songFrequencies        [0][112] = 14'd186;
   assign songFrequencyAmplitudes[0][112] =  8'd27;
   assign songFrequencies        [1][112] = 14'd366;
   assign songFrequencyAmplitudes[1][112] =  8'd25;
   assign songFrequencies        [2][112] = 14'd313;
   assign songFrequencyAmplitudes[2][112] =  8'd23;
   //--
   assign songFrequencies        [0][113] = 14'd186;
   assign songFrequencyAmplitudes[0][113] =  8'd23;
   assign songFrequencies        [1][113] = 14'd313;
   assign songFrequencyAmplitudes[1][113] =  8'd23;
   assign songFrequencies        [2][113] = 14'd366;
   assign songFrequencyAmplitudes[2][113] =  8'd22;
   //--
   assign songFrequencies        [0][114] = 14'd186;
   assign songFrequencyAmplitudes[0][114] =  8'd24;
   assign songFrequencies        [1][114] = 14'd313;
   assign songFrequencyAmplitudes[1][114] =  8'd23;
   assign songFrequencies        [2][114] = 14'd366;
   assign songFrequencyAmplitudes[2][114] =  8'd20;
   //--
   assign songFrequencies        [0][115] = 14'd186;
   assign songFrequencyAmplitudes[0][115] =  8'd24;
   assign songFrequencies        [1][115] = 14'd313;
   assign songFrequencyAmplitudes[1][115] =  8'd21;
   assign songFrequencies        [2][115] = 14'd366;
   assign songFrequencyAmplitudes[2][115] =  8'd18;
   //--
   assign songFrequencies        [0][116] = 14'd186;
   assign songFrequencyAmplitudes[0][116] =  8'd27;
   assign songFrequencies        [1][116] = 14'd313;
   assign songFrequencyAmplitudes[1][116] =  8'd21;
   assign songFrequencies        [2][116] = 14'd366;
   assign songFrequencyAmplitudes[2][116] =  8'd16;
   //--
   assign songFrequencies        [0][117] = 14'd180;
   assign songFrequencyAmplitudes[0][117] =  8'd22;
   assign songFrequencies        [1][117] = 14'd186;
   assign songFrequencyAmplitudes[1][117] =  8'd21;
   assign songFrequencies        [2][117] = 14'd313;
   assign songFrequencyAmplitudes[2][117] =  8'd21;
   //--
   assign songFrequencies        [0][118] = 14'd186;
   assign songFrequencyAmplitudes[0][118] =  8'd30;
   assign songFrequencies        [1][118] = 14'd180;
   assign songFrequencyAmplitudes[1][118] =  8'd26;
   assign songFrequencies        [2][118] = 14'd313;
   assign songFrequencyAmplitudes[2][118] =  8'd18;
   //--
   assign songFrequencies        [0][119] = 14'd186;
   assign songFrequencyAmplitudes[0][119] =  8'd46;
   assign songFrequencies        [1][119] = 14'd180;
   assign songFrequencyAmplitudes[1][119] =  8'd19;
   assign songFrequencies        [2][119] = 14'd373;
   assign songFrequencyAmplitudes[2][119] =  8'd19;
   //--
   assign songFrequencies        [0][120] = 14'd186;
   assign songFrequencyAmplitudes[0][120] =  8'd47;
   assign songFrequencies        [1][120] = 14'd180;
   assign songFrequencyAmplitudes[1][120] =  8'd22;
   assign songFrequencies        [2][120] = 14'd366;
   assign songFrequencyAmplitudes[2][120] =  8'd18;
   //--
   assign songFrequencies        [0][121] = 14'd186;
   assign songFrequencyAmplitudes[0][121] =  8'd48;
   assign songFrequencies        [1][121] = 14'd366;
   assign songFrequencyAmplitudes[1][121] =  8'd21;
   assign songFrequencies        [2][121] = 14'd180;
   assign songFrequencyAmplitudes[2][121] =  8'd20;
   //--
   assign songFrequencies        [0][122] = 14'd186;
   assign songFrequencyAmplitudes[0][122] =  8'd46;
   assign songFrequencies        [1][122] = 14'd246;
   assign songFrequencyAmplitudes[1][122] =  8'd20;
   assign songFrequencies        [2][122] = 14'd366;
   assign songFrequencyAmplitudes[2][122] =  8'd19;
   //--
   assign songFrequencies        [0][123] = 14'd186;
   assign songFrequencyAmplitudes[0][123] =  8'd44;
   assign songFrequencies        [1][123] = 14'd246;
   assign songFrequencyAmplitudes[1][123] =  8'd23;
   assign songFrequencies        [2][123] = 14'd493;
   assign songFrequencyAmplitudes[2][123] =  8'd22;
   //--
   assign songFrequencies        [0][124] = 14'd186;
   assign songFrequencyAmplitudes[0][124] =  8'd43;
   assign songFrequencies        [1][124] = 14'd246;
   assign songFrequencyAmplitudes[1][124] =  8'd24;
   assign songFrequencies        [2][124] = 14'd180;
   assign songFrequencyAmplitudes[2][124] =  8'd21;
   //--
   assign songFrequencies        [0][125] = 14'd186;
   assign songFrequencyAmplitudes[0][125] =  8'd43;
   assign songFrequencies        [1][125] = 14'd246;
   assign songFrequencyAmplitudes[1][125] =  8'd27;
   assign songFrequencies        [2][125] = 14'd180;
   assign songFrequencyAmplitudes[2][125] =  8'd21;
   //--
   assign songFrequencies        [0][126] = 14'd186;
   assign songFrequencyAmplitudes[0][126] =  8'd43;
   assign songFrequencies        [1][126] = 14'd246;
   assign songFrequencyAmplitudes[1][126] =  8'd28;
   assign songFrequencies        [2][126] = 14'd180;
   assign songFrequencyAmplitudes[2][126] =  8'd21;
   //--
   assign songFrequencies        [0][127] = 14'd186;
   assign songFrequencyAmplitudes[0][127] =  8'd42;
   assign songFrequencies        [1][127] = 14'd246;
   assign songFrequencyAmplitudes[1][127] =  8'd28;
   assign songFrequencies        [2][127] = 14'd180;
   assign songFrequencyAmplitudes[2][127] =  8'd19;
   //--
   assign songFrequencies        [0][128] = 14'd186;
   assign songFrequencyAmplitudes[0][128] =  8'd38;
   assign songFrequencies        [1][128] = 14'd246;
   assign songFrequencyAmplitudes[1][128] =  8'd24;
   assign songFrequencies        [2][128] = 14'd180;
   assign songFrequencyAmplitudes[2][128] =  8'd19;
   //--
   assign songFrequencies        [0][129] = 14'd186;
   assign songFrequencyAmplitudes[0][129] =  8'd36;
   assign songFrequencies        [1][129] = 14'd180;
   assign songFrequencyAmplitudes[1][129] =  8'd19;
   assign songFrequencies        [2][129] = 14'd246;
   assign songFrequencyAmplitudes[2][129] =  8'd18;
   //--
   assign songFrequencies        [0][130] = 14'd186;
   assign songFrequencyAmplitudes[0][130] =  8'd35;
   assign songFrequencies        [1][130] = 14'd180;
   assign songFrequencyAmplitudes[1][130] =  8'd18;
   assign songFrequencies        [2][130] = 14'd493;
   assign songFrequencyAmplitudes[2][130] =  8'd11;
   //--
   assign songFrequencies        [0][131] = 14'd186;
   assign songFrequencyAmplitudes[0][131] =  8'd36;
   assign songFrequencies        [1][131] = 14'd180;
   assign songFrequencyAmplitudes[1][131] =  8'd15;
   assign songFrequencies        [2][131] = 14'd253;
   assign songFrequencyAmplitudes[2][131] =  8'd11;
   //--
   assign songFrequencies        [0][132] = 14'd186;
   assign songFrequencyAmplitudes[0][132] =  8'd35;
   assign songFrequencies        [1][132] = 14'd180;
   assign songFrequencyAmplitudes[1][132] =  8'd18;
   assign songFrequencies        [2][132] = 14'd246;
   assign songFrequencyAmplitudes[2][132] =  8'd11;
   //--
   assign songFrequencies        [0][133] = 14'd186;
   assign songFrequencyAmplitudes[0][133] =  8'd31;
   assign songFrequencies        [1][133] = 14'd180;
   assign songFrequencyAmplitudes[1][133] =  8'd21;
   assign songFrequencies        [2][133] = 14'd246;
   assign songFrequencyAmplitudes[2][133] =  8'd16;
   //--
   assign songFrequencies        [0][134] = 14'd313;
   assign songFrequencyAmplitudes[0][134] =  8'd33;
   assign songFrequencies        [1][134] = 14'd186;
   assign songFrequencyAmplitudes[1][134] =  8'd31;
   assign songFrequencies        [2][134] = 14'd306;
   assign songFrequencyAmplitudes[2][134] =  8'd26;
   //--
   assign songFrequencies        [0][135] = 14'd313;
   assign songFrequencyAmplitudes[0][135] =  8'd59;
   assign songFrequencies        [1][135] = 14'd306;
   assign songFrequencyAmplitudes[1][135] =  8'd30;
   assign songFrequencies        [2][135] = 14'd186;
   assign songFrequencyAmplitudes[2][135] =  8'd26;
   //--
   assign songFrequencies        [0][136] = 14'd313;
   assign songFrequencyAmplitudes[0][136] =  8'd71;
   assign songFrequencies        [1][136] = 14'd306;
   assign songFrequencyAmplitudes[1][136] =  8'd34;
   assign songFrequencies        [2][136] = 14'd246;
   assign songFrequencyAmplitudes[2][136] =  8'd23;
   //--
   assign songFrequencies        [0][137] = 14'd313;
   assign songFrequencyAmplitudes[0][137] =  8'd70;
   assign songFrequencies        [1][137] = 14'd306;
   assign songFrequencyAmplitudes[1][137] =  8'd38;
   assign songFrequencies        [2][137] = 14'd620;
   assign songFrequencyAmplitudes[2][137] =  8'd25;
   //--
   assign songFrequencies        [0][138] = 14'd313;
   assign songFrequencyAmplitudes[0][138] =  8'd68;
   assign songFrequencies        [1][138] = 14'd306;
   assign songFrequencyAmplitudes[1][138] =  8'd38;
   assign songFrequencies        [2][138] = 14'd620;
   assign songFrequencyAmplitudes[2][138] =  8'd24;
   //--
   assign songFrequencies        [0][139] = 14'd313;
   assign songFrequencyAmplitudes[0][139] =  8'd67;
   assign songFrequencies        [1][139] = 14'd306;
   assign songFrequencyAmplitudes[1][139] =  8'd33;
   assign songFrequencies        [2][139] = 14'd126;
   assign songFrequencyAmplitudes[2][139] =  8'd20;
   //--
   assign songFrequencies        [0][140] = 14'd313;
   assign songFrequencyAmplitudes[0][140] =  8'd65;
   assign songFrequencies        [1][140] = 14'd306;
   assign songFrequencyAmplitudes[1][140] =  8'd32;
   assign songFrequencies        [2][140] = 14'd620;
   assign songFrequencyAmplitudes[2][140] =  8'd22;
   //--
   assign songFrequencies        [0][141] = 14'd313;
   assign songFrequencyAmplitudes[0][141] =  8'd59;
   assign songFrequencies        [1][141] = 14'd306;
   assign songFrequencyAmplitudes[1][141] =  8'd31;
   assign songFrequencies        [2][141] = 14'd620;
   assign songFrequencyAmplitudes[2][141] =  8'd26;
   //--
   assign songFrequencies        [0][142] = 14'd313;
   assign songFrequencyAmplitudes[0][142] =  8'd52;
   assign songFrequencies        [1][142] = 14'd306;
   assign songFrequencyAmplitudes[1][142] =  8'd26;
   assign songFrequencies        [2][142] = 14'd620;
   assign songFrequencyAmplitudes[2][142] =  8'd21;
   //--
   assign songFrequencies        [0][143] = 14'd313;
   assign songFrequencyAmplitudes[0][143] =  8'd42;
   assign songFrequencies        [1][143] = 14'd306;
   assign songFrequencyAmplitudes[1][143] =  8'd22;
   assign songFrequencies        [2][143] = 14'd246;
   assign songFrequencyAmplitudes[2][143] =  8'd16;
   //--
   assign songFrequencies        [0][144] = 14'd313;
   assign songFrequencyAmplitudes[0][144] =  8'd32;
   assign songFrequencies        [1][144] = 14'd306;
   assign songFrequencyAmplitudes[1][144] =  8'd23;
   assign songFrequencies        [2][144] = 14'd626;
   assign songFrequencyAmplitudes[2][144] =  8'd16;
   //--
   assign songFrequencies        [0][145] = 14'd313;
   assign songFrequencyAmplitudes[0][145] =  8'd26;
   assign songFrequencies        [1][145] = 14'd306;
   assign songFrequencyAmplitudes[1][145] =  8'd19;
   assign songFrequencies        [2][145] = 14'd620;
   assign songFrequencyAmplitudes[2][145] =  8'd17;
   //--
   assign songFrequencies        [0][146] = 14'd313;
   assign songFrequencyAmplitudes[0][146] =  8'd22;
   assign songFrequencies        [1][146] = 14'd620;
   assign songFrequencyAmplitudes[1][146] =  8'd16;
   assign songFrequencies        [2][146] = 14'd306;
   assign songFrequencyAmplitudes[2][146] =  8'd15;
   //--
   assign songFrequencies        [0][147] = 14'd313;
   assign songFrequencyAmplitudes[0][147] =  8'd17;
   assign songFrequencies        [1][147] = 14'd620;
   assign songFrequencyAmplitudes[1][147] =  8'd16;
   assign songFrequencies        [2][147] = 14'd246;
   assign songFrequencyAmplitudes[2][147] =  8'd14;
   //--
   assign songFrequencies        [0][148] = 14'd620;
   assign songFrequencyAmplitudes[0][148] =  8'd19;
   assign songFrequencies        [1][148] = 14'd246;
   assign songFrequencyAmplitudes[1][148] =  8'd14;
   assign songFrequencies        [2][148] = 14'd313;
   assign songFrequencyAmplitudes[2][148] =  8'd13;
   //--
   assign songFrequencies        [0][149] = 14'd620;
   assign songFrequencyAmplitudes[0][149] =  8'd21;
   assign songFrequencies        [1][149] = 14'd246;
   assign songFrequencyAmplitudes[1][149] =  8'd14;
   assign songFrequencies        [2][149] = 14'd313;
   assign songFrequencyAmplitudes[2][149] =  8'd11;
   //--
   assign songFrequencies        [0][150] = 14'd620;
   assign songFrequencyAmplitudes[0][150] =  8'd18;
   assign songFrequencies        [1][150] = 14'd246;
   assign songFrequencyAmplitudes[1][150] =  8'd15;
   assign songFrequencies        [2][150] = 14'd313;
   assign songFrequencyAmplitudes[2][150] =  8'd11;
   //--
   assign songFrequencies        [0][151] = 14'd246;
   assign songFrequencyAmplitudes[0][151] =  8'd16;
   assign songFrequencies        [1][151] = 14'd620;
   assign songFrequencyAmplitudes[1][151] =  8'd13;
   assign songFrequencies        [2][151] = 14'd313;
   assign songFrequencyAmplitudes[2][151] =  8'd13;
   //--
   assign songFrequencies        [0][152] = 14'd246;
   assign songFrequencyAmplitudes[0][152] =  8'd16;
   assign songFrequencies        [1][152] = 14'd313;
   assign songFrequencyAmplitudes[1][152] =  8'd13;
   assign songFrequencies        [2][152] = 14'd620;
   assign songFrequencyAmplitudes[2][152] =  8'd11;
   //--
   assign songFrequencies        [0][153] = 14'd246;
   assign songFrequencyAmplitudes[0][153] =  8'd14;
   assign songFrequencies        [1][153] = 14'd313;
   assign songFrequencyAmplitudes[1][153] =  8'd13;
   assign songFrequencies        [2][153] = 14'd620;
   assign songFrequencyAmplitudes[2][153] =  8'd11;
   //--
   assign songFrequencies        [0][154] = 14'd246;
   assign songFrequencyAmplitudes[0][154] =  8'd12;
   assign songFrequencies        [1][154] = 14'd313;
   assign songFrequencyAmplitudes[1][154] =  8'd12;
   assign songFrequencies        [2][154] = 14'd620;
   assign songFrequencyAmplitudes[2][154] =  8'd10;
   //--
   assign songFrequencies        [0][155] = 14'd313;
   assign songFrequencyAmplitudes[0][155] =  8'd11;
   assign songFrequencies        [1][155] = 14'd246;
   assign songFrequencyAmplitudes[1][155] =  8'd11;
   assign songFrequencies        [2][155] = 14'd620;
   assign songFrequencyAmplitudes[2][155] =  8'd7;
   //--
   assign songFrequencies        [0][156] = 14'd313;
   assign songFrequencyAmplitudes[0][156] =  8'd11;
   assign songFrequencies        [1][156] = 14'd246;
   assign songFrequencyAmplitudes[1][156] =  8'd10;
   assign songFrequencies        [2][156] = 14'd306;
   assign songFrequencyAmplitudes[2][156] =  8'd6;
   //--
   assign songFrequencies        [0][157] = 14'd313;
   assign songFrequencyAmplitudes[0][157] =  8'd11;
   assign songFrequencies        [1][157] = 14'd246;
   assign songFrequencyAmplitudes[1][157] =  8'd10;
   assign songFrequencies        [2][157] = 14'd620;
   assign songFrequencyAmplitudes[2][157] =  8'd5;
   //--
   assign songFrequencies        [0][158] = 14'd313;
   assign songFrequencyAmplitudes[0][158] =  8'd10;
   assign songFrequencies        [1][158] = 14'd246;
   assign songFrequencyAmplitudes[1][158] =  8'd9;
   assign songFrequencies        [2][158] = 14'd620;
   assign songFrequencyAmplitudes[2][158] =  8'd6;
   //--
   assign songFrequencies        [0][159] = 14'd313;
   assign songFrequencyAmplitudes[0][159] =  8'd10;
   assign songFrequencies        [1][159] = 14'd246;
   assign songFrequencyAmplitudes[1][159] =  8'd9;
   assign songFrequencies        [2][159] = 14'd306;
   assign songFrequencyAmplitudes[2][159] =  8'd5;
   //--
   assign songFrequencies        [0][160] = 14'd313;
   assign songFrequencyAmplitudes[0][160] =  8'd9;
   assign songFrequencies        [1][160] = 14'd246;
   assign songFrequencyAmplitudes[1][160] =  8'd8;
   assign songFrequencies        [2][160] = 14'd306;
   assign songFrequencyAmplitudes[2][160] =  8'd5;
   //--
   assign songFrequencies        [0][161] = 14'd246;
   assign songFrequencyAmplitudes[0][161] =  8'd9;
   assign songFrequencies        [1][161] = 14'd313;
   assign songFrequencyAmplitudes[1][161] =  8'd9;
   assign songFrequencies        [2][161] = 14'd306;
   assign songFrequencyAmplitudes[2][161] =  8'd4;
   //--
   assign songFrequencies        [0][162] = 14'd246;
   assign songFrequencyAmplitudes[0][162] =  8'd9;
   assign songFrequencies        [1][162] = 14'd313;
   assign songFrequencyAmplitudes[1][162] =  8'd8;
   assign songFrequencies        [2][162] = 14'd306;
   assign songFrequencyAmplitudes[2][162] =  8'd4;
   //--
   assign songFrequencies        [0][163] = 14'd246;
   assign songFrequencyAmplitudes[0][163] =  8'd8;
   assign songFrequencies        [1][163] = 14'd313;
   assign songFrequencyAmplitudes[1][163] =  8'd8;
   assign songFrequencies        [2][163] = 14'd306;
   assign songFrequencyAmplitudes[2][163] =  8'd4;
   //--
   assign songFrequencies        [0][164] = 14'd246;
   assign songFrequencyAmplitudes[0][164] =  8'd7;
   assign songFrequencies        [1][164] = 14'd313;
   assign songFrequencyAmplitudes[1][164] =  8'd7;
   assign songFrequencies        [2][164] = 14'd306;
   assign songFrequencyAmplitudes[2][164] =  8'd4;
   //--
   assign songFrequencies        [0][165] = 14'd246;
   assign songFrequencyAmplitudes[0][165] =  8'd7;
   assign songFrequencies        [1][165] = 14'd313;
   assign songFrequencyAmplitudes[1][165] =  8'd7;
   assign songFrequencies        [2][165] = 14'd306;
   assign songFrequencyAmplitudes[2][165] =  8'd4;
   //--
   assign songFrequencies        [0][166] = 14'd246;
   assign songFrequencyAmplitudes[0][166] =  8'd7;
   assign songFrequencies        [1][166] = 14'd313;
   assign songFrequencyAmplitudes[1][166] =  8'd6;
   assign songFrequencies        [2][166] = 14'd306;
   assign songFrequencyAmplitudes[2][166] =  8'd3;
   //--
   assign songFrequencies        [0][167] = 14'd246;
   assign songFrequencyAmplitudes[0][167] =  8'd6;
   assign songFrequencies        [1][167] = 14'd313;
   assign songFrequencyAmplitudes[1][167] =  8'd6;
   assign songFrequencies        [2][167] = 14'd306;
   assign songFrequencyAmplitudes[2][167] =  8'd3;
   //--
   assign songFrequencies        [0][168] = 14'd313;
   assign songFrequencyAmplitudes[0][168] =  8'd6;
   assign songFrequencies        [1][168] = 14'd246;
   assign songFrequencyAmplitudes[1][168] =  8'd5;
   assign songFrequencies        [2][168] = 14'd306;
   assign songFrequencyAmplitudes[2][168] =  8'd3;
   //--
   assign songFrequencies        [0][169] = 14'd313;
   assign songFrequencyAmplitudes[0][169] =  8'd5;
   assign songFrequencies        [1][169] = 14'd246;
   assign songFrequencyAmplitudes[1][169] =  8'd5;
   assign songFrequencies        [2][169] = 14'd306;
   assign songFrequencyAmplitudes[2][169] =  8'd3;
   //--
   assign songFrequencies        [0][170] = 14'd246;
   assign songFrequencyAmplitudes[0][170] =  8'd5;
   assign songFrequencies        [1][170] = 14'd313;
   assign songFrequencyAmplitudes[1][170] =  8'd5;
   assign songFrequencies        [2][170] = 14'd306;
   assign songFrequencyAmplitudes[2][170] =  8'd3;
   //--
   assign songFrequencies        [0][171] = 14'd246;
   assign songFrequencyAmplitudes[0][171] =  8'd5;
   assign songFrequencies        [1][171] = 14'd313;
   assign songFrequencyAmplitudes[1][171] =  8'd5;
   assign songFrequencies        [2][171] = 14'd306;
   assign songFrequencyAmplitudes[2][171] =  8'd3;
   //--
   assign songFrequencies        [0][172] = 14'd246;
   assign songFrequencyAmplitudes[0][172] =  8'd5;
   assign songFrequencies        [1][172] = 14'd313;
   assign songFrequencyAmplitudes[1][172] =  8'd5;
   assign songFrequencies        [2][172] = 14'd306;
   assign songFrequencyAmplitudes[2][172] =  8'd2;
   //--
   assign songFrequencies        [0][173] = 14'd253;
   assign songFrequencyAmplitudes[0][173] =  8'd8;
   assign songFrequencies        [1][173] = 14'd246;
   assign songFrequencyAmplitudes[1][173] =  8'd8;
   assign songFrequencies        [2][173] = 14'd240;
   assign songFrequencyAmplitudes[2][173] =  8'd7;
   //--
   assign songFrequencies        [0][174] = 14'd246;
   assign songFrequencyAmplitudes[0][174] =  8'd20;
   assign songFrequencies        [1][174] = 14'd240;
   assign songFrequencyAmplitudes[1][174] =  8'd12;
   assign songFrequencies        [2][174] = 14'd620;
   assign songFrequencyAmplitudes[2][174] =  8'd11;
   //--
   assign songFrequencies        [0][175] = 14'd246;
   assign songFrequencyAmplitudes[0][175] =  8'd33;
   assign songFrequencies        [1][175] = 14'd620;
   assign songFrequencyAmplitudes[1][175] =  8'd17;
   assign songFrequencies        [2][175] = 14'd120;
   assign songFrequencyAmplitudes[2][175] =  8'd11;
   //--
   assign songFrequencies        [0][176] = 14'd246;
   assign songFrequencyAmplitudes[0][176] =  8'd33;
   assign songFrequencies        [1][176] = 14'd620;
   assign songFrequencyAmplitudes[1][176] =  8'd20;
   assign songFrequencies        [2][176] = 14'd120;
   assign songFrequencyAmplitudes[2][176] =  8'd12;
   //--
   assign songFrequencies        [0][177] = 14'd246;
   assign songFrequencyAmplitudes[0][177] =  8'd26;
   assign songFrequencies        [1][177] = 14'd620;
   assign songFrequencyAmplitudes[1][177] =  8'd22;
   assign songFrequencies        [2][177] = 14'd120;
   assign songFrequencyAmplitudes[2][177] =  8'd11;
   //--
   assign songFrequencies        [0][178] = 14'd620;
   assign songFrequencyAmplitudes[0][178] =  8'd22;
   assign songFrequencies        [1][178] = 14'd246;
   assign songFrequencyAmplitudes[1][178] =  8'd16;
   assign songFrequencies        [2][178] = 14'd120;
   assign songFrequencyAmplitudes[2][178] =  8'd13;
   //--
   assign songFrequencies        [0][179] = 14'd620;
   assign songFrequencyAmplitudes[0][179] =  8'd22;
   assign songFrequencies        [1][179] = 14'd120;
   assign songFrequencyAmplitudes[1][179] =  8'd14;
   assign songFrequencies        [2][179] = 14'd433;
   assign songFrequencyAmplitudes[2][179] =  8'd11;
   //--
   assign songFrequencies        [0][180] = 14'd620;
   assign songFrequencyAmplitudes[0][180] =  8'd25;
   assign songFrequencies        [1][180] = 14'd306;
   assign songFrequencyAmplitudes[1][180] =  8'd18;
   assign songFrequencies        [2][180] = 14'd313;
   assign songFrequencyAmplitudes[2][180] =  8'd16;
   //--
   assign songFrequencies        [0][181] = 14'd313;
   assign songFrequencyAmplitudes[0][181] =  8'd27;
   assign songFrequencies        [1][181] = 14'd306;
   assign songFrequencyAmplitudes[1][181] =  8'd26;
   assign songFrequencies        [2][181] = 14'd620;
   assign songFrequencyAmplitudes[2][181] =  8'd25;
   //--
   assign songFrequencies        [0][182] = 14'd313;
   assign songFrequencyAmplitudes[0][182] =  8'd35;
   assign songFrequencies        [1][182] = 14'd306;
   assign songFrequencyAmplitudes[1][182] =  8'd25;
   assign songFrequencies        [2][182] = 14'd153;
   assign songFrequencyAmplitudes[2][182] =  8'd23;
   //--
   assign songFrequencies        [0][183] = 14'd313;
   assign songFrequencyAmplitudes[0][183] =  8'd40;
   assign songFrequencies        [1][183] = 14'd306;
   assign songFrequencyAmplitudes[1][183] =  8'd23;
   assign songFrequencies        [2][183] = 14'd153;
   assign songFrequencyAmplitudes[2][183] =  8'd18;
   //--
   assign songFrequencies        [0][184] = 14'd313;
   assign songFrequencyAmplitudes[0][184] =  8'd38;
   assign songFrequencies        [1][184] = 14'd306;
   assign songFrequencyAmplitudes[1][184] =  8'd22;
   assign songFrequencies        [2][184] = 14'd126;
   assign songFrequencyAmplitudes[2][184] =  8'd22;
   //--
   assign songFrequencies        [0][185] = 14'd313;
   assign songFrequencyAmplitudes[0][185] =  8'd37;
   assign songFrequencies        [1][185] = 14'd246;
   assign songFrequencyAmplitudes[1][185] =  8'd28;
   assign songFrequencies        [2][185] = 14'd126;
   assign songFrequencyAmplitudes[2][185] =  8'd22;
   //--
   assign songFrequencies        [0][186] = 14'd313;
   assign songFrequencyAmplitudes[0][186] =  8'd36;
   assign songFrequencies        [1][186] = 14'd246;
   assign songFrequencyAmplitudes[1][186] =  8'd27;
   assign songFrequencies        [2][186] = 14'd120;
   assign songFrequencyAmplitudes[2][186] =  8'd22;
   //--
   assign songFrequencies        [0][187] = 14'd313;
   assign songFrequencyAmplitudes[0][187] =  8'd30;
   assign songFrequencies        [1][187] = 14'd120;
   assign songFrequencyAmplitudes[1][187] =  8'd23;
   assign songFrequencies        [2][187] = 14'd246;
   assign songFrequencyAmplitudes[2][187] =  8'd22;
   //--
   assign songFrequencies        [0][188] = 14'd313;
   assign songFrequencyAmplitudes[0][188] =  8'd27;
   assign songFrequencies        [1][188] = 14'd186;
   assign songFrequencyAmplitudes[1][188] =  8'd27;
   assign songFrequencies        [2][188] = 14'd120;
   assign songFrequencyAmplitudes[2][188] =  8'd22;
   //--
   assign songFrequencies        [0][189] = 14'd186;
   assign songFrequencyAmplitudes[0][189] =  8'd30;
   assign songFrequencies        [1][189] = 14'd126;
   assign songFrequencyAmplitudes[1][189] =  8'd23;
   assign songFrequencies        [2][189] = 14'd313;
   assign songFrequencyAmplitudes[2][189] =  8'd22;
   //--
   assign songFrequencies        [0][190] = 14'd186;
   assign songFrequencyAmplitudes[0][190] =  8'd26;
   assign songFrequencies        [1][190] = 14'd313;
   assign songFrequencyAmplitudes[1][190] =  8'd21;
   assign songFrequencies        [2][190] = 14'd366;
   assign songFrequencyAmplitudes[2][190] =  8'd19;
   //--
   assign songFrequencies        [0][191] = 14'd186;
   assign songFrequencyAmplitudes[0][191] =  8'd26;
   assign songFrequencies        [1][191] = 14'd313;
   assign songFrequencyAmplitudes[1][191] =  8'd22;
   assign songFrequencies        [2][191] = 14'd366;
   assign songFrequencyAmplitudes[2][191] =  8'd18;
   //--
   assign songFrequencies        [0][192] = 14'd313;
   assign songFrequencyAmplitudes[0][192] =  8'd24;
   assign songFrequencies        [1][192] = 14'd186;
   assign songFrequencyAmplitudes[1][192] =  8'd21;
   assign songFrequencies        [2][192] = 14'd366;
   assign songFrequencyAmplitudes[2][192] =  8'd16;
   //--
   assign songFrequencies        [0][193] = 14'd313;
   assign songFrequencyAmplitudes[0][193] =  8'd24;
   assign songFrequencies        [1][193] = 14'd186;
   assign songFrequencyAmplitudes[1][193] =  8'd23;
   assign songFrequencies        [2][193] = 14'd366;
   assign songFrequencyAmplitudes[2][193] =  8'd18;
   //--
   assign songFrequencies        [0][194] = 14'd186;
   assign songFrequencyAmplitudes[0][194] =  8'd24;
   assign songFrequencies        [1][194] = 14'd313;
   assign songFrequencyAmplitudes[1][194] =  8'd23;
   assign songFrequencies        [2][194] = 14'd366;
   assign songFrequencyAmplitudes[2][194] =  8'd20;
   //--
   assign songFrequencies        [0][195] = 14'd186;
   assign songFrequencyAmplitudes[0][195] =  8'd25;
   assign songFrequencies        [1][195] = 14'd313;
   assign songFrequencyAmplitudes[1][195] =  8'd22;
   assign songFrequencies        [2][195] = 14'd366;
   assign songFrequencyAmplitudes[2][195] =  8'd21;
   //--
   assign songFrequencies        [0][196] = 14'd186;
   assign songFrequencyAmplitudes[0][196] =  8'd30;
   assign songFrequencies        [1][196] = 14'd366;
   assign songFrequencyAmplitudes[1][196] =  8'd29;
   assign songFrequencies        [2][196] = 14'd313;
   assign songFrequencyAmplitudes[2][196] =  8'd21;
   //--
   assign songFrequencies        [0][197] = 14'd186;
   assign songFrequencyAmplitudes[0][197] =  8'd42;
   assign songFrequencies        [1][197] = 14'd366;
   assign songFrequencyAmplitudes[1][197] =  8'd36;
   assign songFrequencies        [2][197] = 14'd373;
   assign songFrequencyAmplitudes[2][197] =  8'd25;
   //--
   assign songFrequencies        [0][198] = 14'd186;
   assign songFrequencyAmplitudes[0][198] =  8'd53;
   assign songFrequencies        [1][198] = 14'd366;
   assign songFrequencyAmplitudes[1][198] =  8'd37;
   assign songFrequencies        [2][198] = 14'd373;
   assign songFrequencyAmplitudes[2][198] =  8'd36;
   //--
   assign songFrequencies        [0][199] = 14'd186;
   assign songFrequencyAmplitudes[0][199] =  8'd53;
   assign songFrequencies        [1][199] = 14'd366;
   assign songFrequencyAmplitudes[1][199] =  8'd38;
   assign songFrequencies        [2][199] = 14'd373;
   assign songFrequencyAmplitudes[2][199] =  8'd34;
   //--
   assign songFrequencies        [0][200] = 14'd186;
   assign songFrequencyAmplitudes[0][200] =  8'd50;
   assign songFrequencies        [1][200] = 14'd366;
   assign songFrequencyAmplitudes[1][200] =  8'd34;
   assign songFrequencies        [2][200] = 14'd373;
   assign songFrequencyAmplitudes[2][200] =  8'd31;
   //--
   assign songFrequencies        [0][201] = 14'd186;
   assign songFrequencyAmplitudes[0][201] =  8'd47;
   assign songFrequencies        [1][201] = 14'd366;
   assign songFrequencyAmplitudes[1][201] =  8'd28;
   assign songFrequencies        [2][201] = 14'd373;
   assign songFrequencyAmplitudes[2][201] =  8'd24;
   //--
   assign songFrequencies        [0][202] = 14'd186;
   assign songFrequencyAmplitudes[0][202] =  8'd47;
   assign songFrequencies        [1][202] = 14'd366;
   assign songFrequencyAmplitudes[1][202] =  8'd24;
   assign songFrequencies        [2][202] = 14'd493;
   assign songFrequencyAmplitudes[2][202] =  8'd24;
   //--
   assign songFrequencies        [0][203] = 14'd186;
   assign songFrequencyAmplitudes[0][203] =  8'd46;
   assign songFrequencies        [1][203] = 14'd493;
   assign songFrequencyAmplitudes[1][203] =  8'd25;
   assign songFrequencies        [2][203] = 14'd180;
   assign songFrequencyAmplitudes[2][203] =  8'd21;
   //--
   assign songFrequencies        [0][204] = 14'd186;
   assign songFrequencyAmplitudes[0][204] =  8'd45;
   assign songFrequencies        [1][204] = 14'd493;
   assign songFrequencyAmplitudes[1][204] =  8'd24;
   assign songFrequencies        [2][204] = 14'd246;
   assign songFrequencyAmplitudes[2][204] =  8'd22;
   //--
   assign songFrequencies        [0][205] = 14'd186;
   assign songFrequencyAmplitudes[0][205] =  8'd44;
   assign songFrequencies        [1][205] = 14'd246;
   assign songFrequencyAmplitudes[1][205] =  8'd23;
   assign songFrequencies        [2][205] = 14'd180;
   assign songFrequencyAmplitudes[2][205] =  8'd23;
   //--
   assign songFrequencies        [0][206] = 14'd186;
   assign songFrequencyAmplitudes[0][206] =  8'd43;
   assign songFrequencies        [1][206] = 14'd246;
   assign songFrequencyAmplitudes[1][206] =  8'd30;
   assign songFrequencies        [2][206] = 14'd180;
   assign songFrequencyAmplitudes[2][206] =  8'd20;
   //--
   assign songFrequencies        [0][207] = 14'd186;
   assign songFrequencyAmplitudes[0][207] =  8'd39;
   assign songFrequencies        [1][207] = 14'd246;
   assign songFrequencyAmplitudes[1][207] =  8'd37;
   assign songFrequencies        [2][207] = 14'd126;
   assign songFrequencyAmplitudes[2][207] =  8'd23;
   //--
   assign songFrequencies        [0][208] = 14'd246;
   assign songFrequencyAmplitudes[0][208] =  8'd47;
   assign songFrequencies        [1][208] = 14'd186;
   assign songFrequencyAmplitudes[1][208] =  8'd38;
   assign songFrequencies        [2][208] = 14'd126;
   assign songFrequencyAmplitudes[2][208] =  8'd24;
   //--
   assign songFrequencies        [0][209] = 14'd246;
   assign songFrequencyAmplitudes[0][209] =  8'd43;
   assign songFrequencies        [1][209] = 14'd186;
   assign songFrequencyAmplitudes[1][209] =  8'd38;
   assign songFrequencies        [2][209] = 14'd120;
   assign songFrequencyAmplitudes[2][209] =  8'd20;
   //--
   assign songFrequencies        [0][210] = 14'd186;
   assign songFrequencyAmplitudes[0][210] =  8'd37;
   assign songFrequencies        [1][210] = 14'd246;
   assign songFrequencyAmplitudes[1][210] =  8'd36;
   assign songFrequencies        [2][210] = 14'd126;
   assign songFrequencyAmplitudes[2][210] =  8'd20;
   //--
   assign songFrequencies        [0][211] = 14'd186;
   assign songFrequencyAmplitudes[0][211] =  8'd36;
   assign songFrequencies        [1][211] = 14'd246;
   assign songFrequencyAmplitudes[1][211] =  8'd28;
   assign songFrequencies        [2][211] = 14'd180;
   assign songFrequencyAmplitudes[2][211] =  8'd19;
   //--
   assign songFrequencies        [0][212] = 14'd186;
   assign songFrequencyAmplitudes[0][212] =  8'd35;
   assign songFrequencies        [1][212] = 14'd246;
   assign songFrequencyAmplitudes[1][212] =  8'd22;
   assign songFrequencies        [2][212] = 14'd126;
   assign songFrequencyAmplitudes[2][212] =  8'd20;
   //--
   assign songFrequencies        [0][213] = 14'd186;
   assign songFrequencyAmplitudes[0][213] =  8'd32;
   assign songFrequencies        [1][213] = 14'd246;
   assign songFrequencyAmplitudes[1][213] =  8'd19;
   assign songFrequencies        [2][213] = 14'd126;
   assign songFrequencyAmplitudes[2][213] =  8'd19;
   //--
   assign songFrequencies        [0][214] = 14'd186;
   assign songFrequencyAmplitudes[0][214] =  8'd28;
   assign songFrequencies        [1][214] = 14'd246;
   assign songFrequencyAmplitudes[1][214] =  8'd19;
   assign songFrequencies        [2][214] = 14'd126;
   assign songFrequencyAmplitudes[2][214] =  8'd16;
   //--
   assign songFrequencies        [0][215] = 14'd246;
   assign songFrequencyAmplitudes[0][215] =  8'd24;
   assign songFrequencies        [1][215] = 14'd186;
   assign songFrequencyAmplitudes[1][215] =  8'd22;
   assign songFrequencies        [2][215] = 14'd620;
   assign songFrequencyAmplitudes[2][215] =  8'd18;
   //--
   assign songFrequencies        [0][216] = 14'd246;
   assign songFrequencyAmplitudes[0][216] =  8'd23;
   assign songFrequencies        [1][216] = 14'd620;
   assign songFrequencyAmplitudes[1][216] =  8'd20;
   assign songFrequencies        [2][216] = 14'd186;
   assign songFrequencyAmplitudes[2][216] =  8'd16;
   //--
   assign songFrequencies        [0][217] = 14'd620;
   assign songFrequencyAmplitudes[0][217] =  8'd21;
   assign songFrequencies        [1][217] = 14'd246;
   assign songFrequencyAmplitudes[1][217] =  8'd19;
   assign songFrequencies        [2][217] = 14'd186;
   assign songFrequencyAmplitudes[2][217] =  8'd14;
   //--
   assign songFrequencies        [0][218] = 14'd620;
   assign songFrequencyAmplitudes[0][218] =  8'd20;
   assign songFrequencies        [1][218] = 14'd246;
   assign songFrequencyAmplitudes[1][218] =  8'd13;
   assign songFrequencies        [2][218] = 14'd120;
   assign songFrequencyAmplitudes[2][218] =  8'd12;
   //--
   assign songFrequencies        [0][219] = 14'd620;
   assign songFrequencyAmplitudes[0][219] =  8'd20;
   assign songFrequencies        [1][219] = 14'd120;
   assign songFrequencyAmplitudes[1][219] =  8'd13;
   assign songFrequencies        [2][219] = 14'd433;
   assign songFrequencyAmplitudes[2][219] =  8'd11;
   //--
   assign songFrequencies        [0][220] = 14'd620;
   assign songFrequencyAmplitudes[0][220] =  8'd19;
   assign songFrequencies        [1][220] = 14'd166;
   assign songFrequencyAmplitudes[1][220] =  8'd18;
   assign songFrequencies        [2][220] = 14'd160;
   assign songFrequencyAmplitudes[2][220] =  8'd16;
   //--
   assign songFrequencies        [0][221] = 14'd166;
   assign songFrequencyAmplitudes[0][221] =  8'd26;
   assign songFrequencies        [1][221] = 14'd326;
   assign songFrequencyAmplitudes[1][221] =  8'd23;
   assign songFrequencies        [2][221] = 14'd620;
   assign songFrequencyAmplitudes[2][221] =  8'd17;
   //--
   assign songFrequencies        [0][222] = 14'd166;
   assign songFrequencyAmplitudes[0][222] =  8'd27;
   assign songFrequencies        [1][222] = 14'd326;
   assign songFrequencyAmplitudes[1][222] =  8'd24;
   assign songFrequencies        [2][222] = 14'd620;
   assign songFrequencyAmplitudes[2][222] =  8'd16;
   //--
   assign songFrequencies        [0][223] = 14'd166;
   assign songFrequencyAmplitudes[0][223] =  8'd21;
   assign songFrequencies        [1][223] = 14'd120;
   assign songFrequencyAmplitudes[1][223] =  8'd18;
   assign songFrequencies        [2][223] = 14'd326;
   assign songFrequencyAmplitudes[2][223] =  8'd17;
   //--
   assign songFrequencies        [0][224] = 14'd120;
   assign songFrequencyAmplitudes[0][224] =  8'd23;
   assign songFrequencies        [1][224] = 14'd166;
   assign songFrequencyAmplitudes[1][224] =  8'd23;
   assign songFrequencies        [2][224] = 14'd126;
   assign songFrequencyAmplitudes[2][224] =  8'd22;
   //--
   assign songFrequencies        [0][225] = 14'd246;
   assign songFrequencyAmplitudes[0][225] =  8'd27;
   assign songFrequencies        [1][225] = 14'd166;
   assign songFrequencyAmplitudes[1][225] =  8'd26;
   assign songFrequencies        [2][225] = 14'd126;
   assign songFrequencyAmplitudes[2][225] =  8'd24;
   //--
   assign songFrequencies        [0][226] = 14'd166;
   assign songFrequencyAmplitudes[0][226] =  8'd29;
   assign songFrequencies        [1][226] = 14'd373;
   assign songFrequencyAmplitudes[1][226] =  8'd22;
   assign songFrequencies        [2][226] = 14'd246;
   assign songFrequencyAmplitudes[2][226] =  8'd22;
   //--
   assign songFrequencies        [0][227] = 14'd413;
   assign songFrequencyAmplitudes[0][227] =  8'd38;
   assign songFrequencies        [1][227] = 14'd420;
   assign songFrequencyAmplitudes[1][227] =  8'd31;
   assign songFrequencies        [2][227] = 14'd166;
   assign songFrequencyAmplitudes[2][227] =  8'd28;
   //--
   assign songFrequencies        [0][228] = 14'd413;
   assign songFrequencyAmplitudes[0][228] =  8'd53;
   assign songFrequencies        [1][228] = 14'd166;
   assign songFrequencyAmplitudes[1][228] =  8'd26;
   assign songFrequencies        [2][228] = 14'd373;
   assign songFrequencyAmplitudes[2][228] =  8'd25;
   //--
   assign songFrequencies        [0][229] = 14'd413;
   assign songFrequencyAmplitudes[0][229] =  8'd50;
   assign songFrequencies        [1][229] = 14'd166;
   assign songFrequencyAmplitudes[1][229] =  8'd25;
   assign songFrequencies        [2][229] = 14'd373;
   assign songFrequencyAmplitudes[2][229] =  8'd21;
   //--
   assign songFrequencies        [0][230] = 14'd413;
   assign songFrequencyAmplitudes[0][230] =  8'd35;
   assign songFrequencies        [1][230] = 14'd166;
   assign songFrequencyAmplitudes[1][230] =  8'd23;
   assign songFrequencies        [2][230] = 14'd420;
   assign songFrequencyAmplitudes[2][230] =  8'd20;
   //--
   assign songFrequencies        [0][231] = 14'd413;
   assign songFrequencyAmplitudes[0][231] =  8'd29;
   assign songFrequencies        [1][231] = 14'd166;
   assign songFrequencyAmplitudes[1][231] =  8'd23;
   assign songFrequencies        [2][231] = 14'd206;
   assign songFrequencyAmplitudes[2][231] =  8'd21;
   //--
   assign songFrequencies        [0][232] = 14'd413;
   assign songFrequencyAmplitudes[0][232] =  8'd28;
   assign songFrequencies        [1][232] = 14'd206;
   assign songFrequencyAmplitudes[1][232] =  8'd22;
   assign songFrequencies        [2][232] = 14'd166;
   assign songFrequencyAmplitudes[2][232] =  8'd20;
   //--
   assign songFrequencies        [0][233] = 14'd413;
   assign songFrequencyAmplitudes[0][233] =  8'd28;
   assign songFrequencies        [1][233] = 14'd206;
   assign songFrequencyAmplitudes[1][233] =  8'd23;
   assign songFrequencies        [2][233] = 14'd166;
   assign songFrequencyAmplitudes[2][233] =  8'd19;
   //--
   assign songFrequencies        [0][234] = 14'd413;
   assign songFrequencyAmplitudes[0][234] =  8'd25;
   assign songFrequencies        [1][234] = 14'd206;
   assign songFrequencyAmplitudes[1][234] =  8'd21;
   assign songFrequencies        [2][234] = 14'd166;
   assign songFrequencyAmplitudes[2][234] =  8'd18;
   //--
   assign songFrequencies        [0][235] = 14'd206;
   assign songFrequencyAmplitudes[0][235] =  8'd19;
   assign songFrequencies        [1][235] = 14'd413;
   assign songFrequencyAmplitudes[1][235] =  8'd19;
   assign songFrequencies        [2][235] = 14'd166;
   assign songFrequencyAmplitudes[2][235] =  8'd17;
   //--
   assign songFrequencies        [0][236] = 14'd413;
   assign songFrequencyAmplitudes[0][236] =  8'd31;
   assign songFrequencies        [1][236] = 14'd166;
   assign songFrequencyAmplitudes[1][236] =  8'd15;
   assign songFrequencies        [2][236] = 14'd373;
   assign songFrequencyAmplitudes[2][236] =  8'd14;
   //--
   assign songFrequencies        [0][237] = 14'd413;
   assign songFrequencyAmplitudes[0][237] =  8'd47;
   assign songFrequencies        [1][237] = 14'd420;
   assign songFrequencyAmplitudes[1][237] =  8'd28;
   assign songFrequencies        [2][237] = 14'd373;
   assign songFrequencyAmplitudes[2][237] =  8'd15;
   //--
   assign songFrequencies        [0][238] = 14'd413;
   assign songFrequencyAmplitudes[0][238] =  8'd57;
   assign songFrequencies        [1][238] = 14'd420;
   assign songFrequencyAmplitudes[1][238] =  8'd24;
   assign songFrequencies        [2][238] = 14'd373;
   assign songFrequencyAmplitudes[2][238] =  8'd15;
   //--
   assign songFrequencies        [0][239] = 14'd413;
   assign songFrequencyAmplitudes[0][239] =  8'd51;
   assign songFrequencies        [1][239] = 14'd420;
   assign songFrequencyAmplitudes[1][239] =  8'd20;
   assign songFrequencies        [2][239] = 14'd166;
   assign songFrequencyAmplitudes[2][239] =  8'd11;
   //--
   assign songFrequencies        [0][240] = 14'd413;
   assign songFrequencyAmplitudes[0][240] =  8'd35;
   assign songFrequencies        [1][240] = 14'd420;
   assign songFrequencyAmplitudes[1][240] =  8'd17;
   assign songFrequencies        [2][240] = 14'd166;
   assign songFrequencyAmplitudes[2][240] =  8'd12;
   //--
   assign songFrequencies        [0][241] = 14'd413;
   assign songFrequencyAmplitudes[0][241] =  8'd28;
   assign songFrequencies        [1][241] = 14'd493;
   assign songFrequencyAmplitudes[1][241] =  8'd18;
   assign songFrequencies        [2][241] = 14'd206;
   assign songFrequencyAmplitudes[2][241] =  8'd15;
   //--
   assign songFrequencies        [0][242] = 14'd413;
   assign songFrequencyAmplitudes[0][242] =  8'd27;
   assign songFrequencies        [1][242] = 14'd493;
   assign songFrequencyAmplitudes[1][242] =  8'd22;
   assign songFrequencies        [2][242] = 14'd246;
   assign songFrequencyAmplitudes[2][242] =  8'd16;
   //--
   assign songFrequencies        [0][243] = 14'd413;
   assign songFrequencyAmplitudes[0][243] =  8'd26;
   assign songFrequencies        [1][243] = 14'd246;
   assign songFrequencyAmplitudes[1][243] =  8'd22;
   assign songFrequencies        [2][243] = 14'd493;
   assign songFrequencyAmplitudes[2][243] =  8'd20;
   //--
   assign songFrequencies        [0][244] = 14'd246;
   assign songFrequencyAmplitudes[0][244] =  8'd25;
   assign songFrequencies        [1][244] = 14'd413;
   assign songFrequencyAmplitudes[1][244] =  8'd23;
   assign songFrequencies        [2][244] = 14'd493;
   assign songFrequencyAmplitudes[2][244] =  8'd19;
   //--
   assign songFrequencies        [0][245] = 14'd246;
   assign songFrequencyAmplitudes[0][245] =  8'd30;
   assign songFrequencies        [1][245] = 14'd413;
   assign songFrequencyAmplitudes[1][245] =  8'd16;
   assign songFrequencies        [2][245] = 14'd493;
   assign songFrequencyAmplitudes[2][245] =  8'd16;
   //--
   assign songFrequencies        [0][246] = 14'd246;
   assign songFrequencyAmplitudes[0][246] =  8'd37;
   assign songFrequencies        [1][246] = 14'd253;
   assign songFrequencyAmplitudes[1][246] =  8'd19;
   assign songFrequencies        [2][246] = 14'd493;
   assign songFrequencyAmplitudes[2][246] =  8'd15;
   //--
   assign songFrequencies        [0][247] = 14'd246;
   assign songFrequencyAmplitudes[0][247] =  8'd43;
   assign songFrequencies        [1][247] = 14'd126;
   assign songFrequencyAmplitudes[1][247] =  8'd22;
   assign songFrequencies        [2][247] = 14'd253;
   assign songFrequencyAmplitudes[2][247] =  8'd18;
   //--
   assign songFrequencies        [0][248] = 14'd246;
   assign songFrequencyAmplitudes[0][248] =  8'd46;
   assign songFrequencies        [1][248] = 14'd126;
   assign songFrequencyAmplitudes[1][248] =  8'd23;
   assign songFrequencies        [2][248] = 14'd120;
   assign songFrequencyAmplitudes[2][248] =  8'd21;
   //--
   assign songFrequencies        [0][249] = 14'd246;
   assign songFrequencyAmplitudes[0][249] =  8'd40;
   assign songFrequencies        [1][249] = 14'd120;
   assign songFrequencyAmplitudes[1][249] =  8'd23;
   assign songFrequencies        [2][249] = 14'd126;
   assign songFrequencyAmplitudes[2][249] =  8'd19;
   //--
   assign songFrequencies        [0][250] = 14'd246;
   assign songFrequencyAmplitudes[0][250] =  8'd34;
   assign songFrequencies        [1][250] = 14'd120;
   assign songFrequencyAmplitudes[1][250] =  8'd21;
   assign songFrequencies        [2][250] = 14'd126;
   assign songFrequencyAmplitudes[2][250] =  8'd19;
   //--
   assign songFrequencies        [0][251] = 14'd246;
   assign songFrequencyAmplitudes[0][251] =  8'd28;
   assign songFrequencies        [1][251] = 14'd126;
   assign songFrequencyAmplitudes[1][251] =  8'd19;
   assign songFrequencies        [2][251] = 14'd120;
   assign songFrequencyAmplitudes[2][251] =  8'd17;
   //--
   assign songFrequencies        [0][252] = 14'd246;
   assign songFrequencyAmplitudes[0][252] =  8'd18;
   assign songFrequencies        [1][252] = 14'd126;
   assign songFrequencyAmplitudes[1][252] =  8'd15;
   assign songFrequencies        [2][252] = 14'd120;
   assign songFrequencyAmplitudes[2][252] =  8'd15;
   //--
   assign songFrequencies        [0][253] = 14'd246;
   assign songFrequencyAmplitudes[0][253] =  8'd14;
   assign songFrequencies        [1][253] = 14'd253;
   assign songFrequencyAmplitudes[1][253] =  8'd12;
   assign songFrequencies        [2][253] = 14'd740;
   assign songFrequencyAmplitudes[2][253] =  8'd12;
   //--
   assign songFrequencies        [0][254] = 14'd246;
   assign songFrequencyAmplitudes[0][254] =  8'd22;
   assign songFrequencies        [1][254] = 14'd620;
   assign songFrequencyAmplitudes[1][254] =  8'd12;
   assign songFrequencies        [2][254] = 14'd740;
   assign songFrequencyAmplitudes[2][254] =  8'd11;
   //--
   assign songFrequencies        [0][255] = 14'd246;
   assign songFrequencyAmplitudes[0][255] =  8'd28;
   assign songFrequencies        [1][255] = 14'd620;
   assign songFrequencyAmplitudes[1][255] =  8'd18;
   assign songFrequencies        [2][255] = 14'd60;
   assign songFrequencyAmplitudes[2][255] =  8'd10;
   //--
   assign songFrequencies        [0][256] = 14'd246;
   assign songFrequencyAmplitudes[0][256] =  8'd26;
   assign songFrequencies        [1][256] = 14'd620;
   assign songFrequencyAmplitudes[1][256] =  8'd19;
   assign songFrequencies        [2][256] = 14'd120;
   assign songFrequencyAmplitudes[2][256] =  8'd11;
   //--
   assign songFrequencies        [0][257] = 14'd620;
   assign songFrequencyAmplitudes[0][257] =  8'd20;
   assign songFrequencies        [1][257] = 14'd246;
   assign songFrequencyAmplitudes[1][257] =  8'd18;
   assign songFrequencies        [2][257] = 14'd120;
   assign songFrequencyAmplitudes[2][257] =  8'd14;
   //--
   assign songFrequencies        [0][258] = 14'd620;
   assign songFrequencyAmplitudes[0][258] =  8'd21;
   assign songFrequencies        [1][258] = 14'd120;
   assign songFrequencyAmplitudes[1][258] =  8'd16;
   assign songFrequencies        [2][258] = 14'd246;
   assign songFrequencyAmplitudes[2][258] =  8'd13;
   //--
   assign songFrequencies        [0][259] = 14'd620;
   assign songFrequencyAmplitudes[0][259] =  8'd24;
   assign songFrequencies        [1][259] = 14'd306;
   assign songFrequencyAmplitudes[1][259] =  8'd18;
   assign songFrequencies        [2][259] = 14'd120;
   assign songFrequencyAmplitudes[2][259] =  8'd16;
   //--
   assign songFrequencies        [0][260] = 14'd306;
   assign songFrequencyAmplitudes[0][260] =  8'd27;
   assign songFrequencies        [1][260] = 14'd313;
   assign songFrequencyAmplitudes[1][260] =  8'd25;
   assign songFrequencies        [2][260] = 14'd620;
   assign songFrequencyAmplitudes[2][260] =  8'd23;
   //--
   assign songFrequencies        [0][261] = 14'd313;
   assign songFrequencyAmplitudes[0][261] =  8'd36;
   assign songFrequencies        [1][261] = 14'd306;
   assign songFrequencyAmplitudes[1][261] =  8'd25;
   assign songFrequencies        [2][261] = 14'd153;
   assign songFrequencyAmplitudes[2][261] =  8'd21;
   //--
   assign songFrequencies        [0][262] = 14'd313;
   assign songFrequencyAmplitudes[0][262] =  8'd38;
   assign songFrequencies        [1][262] = 14'd306;
   assign songFrequencyAmplitudes[1][262] =  8'd28;
   assign songFrequencies        [2][262] = 14'd153;
   assign songFrequencyAmplitudes[2][262] =  8'd17;
   //--
   assign songFrequencies        [0][263] = 14'd313;
   assign songFrequencyAmplitudes[0][263] =  8'd39;
   assign songFrequencies        [1][263] = 14'd306;
   assign songFrequencyAmplitudes[1][263] =  8'd26;
   assign songFrequencies        [2][263] = 14'd246;
   assign songFrequencyAmplitudes[2][263] =  8'd21;
   //--
   assign songFrequencies        [0][264] = 14'd313;
   assign songFrequencyAmplitudes[0][264] =  8'd39;
   assign songFrequencies        [1][264] = 14'd246;
   assign songFrequencyAmplitudes[1][264] =  8'd31;
   assign songFrequencies        [2][264] = 14'd126;
   assign songFrequencyAmplitudes[2][264] =  8'd19;
   //--
   assign songFrequencies        [0][265] = 14'd313;
   assign songFrequencyAmplitudes[0][265] =  8'd35;
   assign songFrequencies        [1][265] = 14'd246;
   assign songFrequencyAmplitudes[1][265] =  8'd31;
   assign songFrequencies        [2][265] = 14'd120;
   assign songFrequencyAmplitudes[2][265] =  8'd22;
   //--
   assign songFrequencies        [0][266] = 14'd313;
   assign songFrequencyAmplitudes[0][266] =  8'd30;
   assign songFrequencies        [1][266] = 14'd246;
   assign songFrequencyAmplitudes[1][266] =  8'd26;
   assign songFrequencies        [2][266] = 14'd126;
   assign songFrequencyAmplitudes[2][266] =  8'd25;
   //--
   assign songFrequencies        [0][267] = 14'd186;
   assign songFrequencyAmplitudes[0][267] =  8'd28;
   assign songFrequencies        [1][267] = 14'd313;
   assign songFrequencyAmplitudes[1][267] =  8'd27;
   assign songFrequencies        [2][267] = 14'd120;
   assign songFrequencyAmplitudes[2][267] =  8'd23;
   //--
   assign songFrequencies        [0][268] = 14'd186;
   assign songFrequencyAmplitudes[0][268] =  8'd31;
   assign songFrequencies        [1][268] = 14'd313;
   assign songFrequencyAmplitudes[1][268] =  8'd24;
   assign songFrequencies        [2][268] = 14'd120;
   assign songFrequencyAmplitudes[2][268] =  8'd20;
   //--
   assign songFrequencies        [0][269] = 14'd186;
   assign songFrequencyAmplitudes[0][269] =  8'd27;
   assign songFrequencies        [1][269] = 14'd313;
   assign songFrequencyAmplitudes[1][269] =  8'd23;
   assign songFrequencies        [2][269] = 14'd366;
   assign songFrequencyAmplitudes[2][269] =  8'd19;
   //--
   assign songFrequencies        [0][270] = 14'd186;
   assign songFrequencyAmplitudes[0][270] =  8'd25;
   assign songFrequencies        [1][270] = 14'd313;
   assign songFrequencyAmplitudes[1][270] =  8'd24;
   assign songFrequencies        [2][270] = 14'd246;
   assign songFrequencyAmplitudes[2][270] =  8'd19;
   //--
   assign songFrequencies        [0][271] = 14'd313;
   assign songFrequencyAmplitudes[0][271] =  8'd27;
   assign songFrequencies        [1][271] = 14'd186;
   assign songFrequencyAmplitudes[1][271] =  8'd23;
   assign songFrequencies        [2][271] = 14'd246;
   assign songFrequencyAmplitudes[2][271] =  8'd18;
   //--
   assign songFrequencies        [0][272] = 14'd313;
   assign songFrequencyAmplitudes[0][272] =  8'd25;
   assign songFrequencies        [1][272] = 14'd186;
   assign songFrequencyAmplitudes[1][272] =  8'd23;
   assign songFrequencies        [2][272] = 14'd366;
   assign songFrequencyAmplitudes[2][272] =  8'd18;
   //--
   assign songFrequencies        [0][273] = 14'd186;
   assign songFrequencyAmplitudes[0][273] =  8'd26;
   assign songFrequencies        [1][273] = 14'd313;
   assign songFrequencyAmplitudes[1][273] =  8'd22;
   assign songFrequencies        [2][273] = 14'd366;
   assign songFrequencyAmplitudes[2][273] =  8'd19;
   //--
   assign songFrequencies        [0][274] = 14'd186;
   assign songFrequencyAmplitudes[0][274] =  8'd25;
   assign songFrequencies        [1][274] = 14'd313;
   assign songFrequencyAmplitudes[1][274] =  8'd20;
   assign songFrequencies        [2][274] = 14'd366;
   assign songFrequencyAmplitudes[2][274] =  8'd19;
   //--
   assign songFrequencies        [0][275] = 14'd186;
   assign songFrequencyAmplitudes[0][275] =  8'd30;
   assign songFrequencies        [1][275] = 14'd366;
   assign songFrequencyAmplitudes[1][275] =  8'd27;
   assign songFrequencies        [2][275] = 14'd313;
   assign songFrequencyAmplitudes[2][275] =  8'd18;
   //--
   assign songFrequencies        [0][276] = 14'd186;
   assign songFrequencyAmplitudes[0][276] =  8'd42;
   assign songFrequencies        [1][276] = 14'd366;
   assign songFrequencyAmplitudes[1][276] =  8'd35;
   assign songFrequencies        [2][276] = 14'd180;
   assign songFrequencyAmplitudes[2][276] =  8'd23;
   //--
   assign songFrequencies        [0][277] = 14'd186;
   assign songFrequencyAmplitudes[0][277] =  8'd54;
   assign songFrequencies        [1][277] = 14'd366;
   assign songFrequencyAmplitudes[1][277] =  8'd36;
   assign songFrequencies        [2][277] = 14'd373;
   assign songFrequencyAmplitudes[2][277] =  8'd32;
   //--
   assign songFrequencies        [0][278] = 14'd186;
   assign songFrequencyAmplitudes[0][278] =  8'd53;
   assign songFrequencies        [1][278] = 14'd366;
   assign songFrequencyAmplitudes[1][278] =  8'd37;
   assign songFrequencies        [2][278] = 14'd373;
   assign songFrequencyAmplitudes[2][278] =  8'd32;
   //--
   assign songFrequencies        [0][279] = 14'd186;
   assign songFrequencyAmplitudes[0][279] =  8'd52;
   assign songFrequencies        [1][279] = 14'd366;
   assign songFrequencyAmplitudes[1][279] =  8'd36;
   assign songFrequencies        [2][279] = 14'd373;
   assign songFrequencyAmplitudes[2][279] =  8'd27;
   //--
   assign songFrequencies        [0][280] = 14'd186;
   assign songFrequencyAmplitudes[0][280] =  8'd49;
   assign songFrequencies        [1][280] = 14'd366;
   assign songFrequencyAmplitudes[1][280] =  8'd30;
   assign songFrequencies        [2][280] = 14'd373;
   assign songFrequencyAmplitudes[2][280] =  8'd22;
   //--
   assign songFrequencies        [0][281] = 14'd186;
   assign songFrequencyAmplitudes[0][281] =  8'd48;
   assign songFrequencies        [1][281] = 14'd366;
   assign songFrequencyAmplitudes[1][281] =  8'd26;
   assign songFrequencies        [2][281] = 14'd180;
   assign songFrequencyAmplitudes[2][281] =  8'd22;
   //--
   assign songFrequencies        [0][282] = 14'd186;
   assign songFrequencyAmplitudes[0][282] =  8'd46;
   assign songFrequencies        [1][282] = 14'd180;
   assign songFrequencyAmplitudes[1][282] =  8'd22;
   assign songFrequencies        [2][282] = 14'd366;
   assign songFrequencyAmplitudes[2][282] =  8'd21;
   //--
   assign songFrequencies        [0][283] = 14'd186;
   assign songFrequencyAmplitudes[0][283] =  8'd45;
   assign songFrequencies        [1][283] = 14'd246;
   assign songFrequencyAmplitudes[1][283] =  8'd24;
   assign songFrequencies        [2][283] = 14'd180;
   assign songFrequencyAmplitudes[2][283] =  8'd22;
   //--
   assign songFrequencies        [0][284] = 14'd186;
   assign songFrequencyAmplitudes[0][284] =  8'd45;
   assign songFrequencies        [1][284] = 14'd246;
   assign songFrequencyAmplitudes[1][284] =  8'd29;
   assign songFrequencies        [2][284] = 14'd180;
   assign songFrequencyAmplitudes[2][284] =  8'd22;
   //--
   assign songFrequencies        [0][285] = 14'd186;
   assign songFrequencyAmplitudes[0][285] =  8'd44;
   assign songFrequencies        [1][285] = 14'd246;
   assign songFrequencyAmplitudes[1][285] =  8'd28;
   assign songFrequencies        [2][285] = 14'd180;
   assign songFrequencyAmplitudes[2][285] =  8'd21;
   //--
   assign songFrequencies        [0][286] = 14'd186;
   assign songFrequencyAmplitudes[0][286] =  8'd41;
   assign songFrequencies        [1][286] = 14'd246;
   assign songFrequencyAmplitudes[1][286] =  8'd25;
   assign songFrequencies        [2][286] = 14'd253;
   assign songFrequencyAmplitudes[2][286] =  8'd19;
   //--
   assign songFrequencies        [0][287] = 14'd186;
   assign songFrequencyAmplitudes[0][287] =  8'd38;
   assign songFrequencies        [1][287] = 14'd246;
   assign songFrequencyAmplitudes[1][287] =  8'd30;
   assign songFrequencies        [2][287] = 14'd126;
   assign songFrequencyAmplitudes[2][287] =  8'd27;
   //--
   assign songFrequencies        [0][288] = 14'd186;
   assign songFrequencyAmplitudes[0][288] =  8'd38;
   assign songFrequencies        [1][288] = 14'd246;
   assign songFrequencyAmplitudes[1][288] =  8'd28;
   assign songFrequencies        [2][288] = 14'd120;
   assign songFrequencyAmplitudes[2][288] =  8'd28;
   //--
   assign songFrequencies        [0][289] = 14'd186;
   assign songFrequencyAmplitudes[0][289] =  8'd38;
   assign songFrequencies        [1][289] = 14'd120;
   assign songFrequencyAmplitudes[1][289] =  8'd26;
   assign songFrequencies        [2][289] = 14'd126;
   assign songFrequencyAmplitudes[2][289] =  8'd25;
   //--
   assign songFrequencies        [0][290] = 14'd186;
   assign songFrequencyAmplitudes[0][290] =  8'd38;
   assign songFrequencies        [1][290] = 14'd120;
   assign songFrequencyAmplitudes[1][290] =  8'd25;
   assign songFrequencies        [2][290] = 14'd126;
   assign songFrequencyAmplitudes[2][290] =  8'd22;
   //--
   assign songFrequencies        [0][291] = 14'd186;
   assign songFrequencyAmplitudes[0][291] =  8'd37;
   assign songFrequencies        [1][291] = 14'd126;
   assign songFrequencyAmplitudes[1][291] =  8'd24;
   assign songFrequencies        [2][291] = 14'd120;
   assign songFrequencyAmplitudes[2][291] =  8'd21;
   //--
   assign songFrequencies        [0][292] = 14'd186;
   assign songFrequencyAmplitudes[0][292] =  8'd34;
   assign songFrequencies        [1][292] = 14'd126;
   assign songFrequencyAmplitudes[1][292] =  8'd24;
   assign songFrequencies        [2][292] = 14'd180;
   assign songFrequencyAmplitudes[2][292] =  8'd16;
   //--
   assign songFrequencies        [0][293] = 14'd186;
   assign songFrequencyAmplitudes[0][293] =  8'd25;
   assign songFrequencies        [1][293] = 14'd246;
   assign songFrequencyAmplitudes[1][293] =  8'd21;
   assign songFrequencies        [2][293] = 14'd126;
   assign songFrequencyAmplitudes[2][293] =  8'd17;
   //--
   assign songFrequencies        [0][294] = 14'd246;
   assign songFrequencyAmplitudes[0][294] =  8'd38;
   assign songFrequencies        [1][294] = 14'd620;
   assign songFrequencyAmplitudes[1][294] =  8'd18;
   assign songFrequencies        [2][294] = 14'd186;
   assign songFrequencyAmplitudes[2][294] =  8'd16;
   //--
   assign songFrequencies        [0][295] = 14'd246;
   assign songFrequencyAmplitudes[0][295] =  8'd38;
   assign songFrequencies        [1][295] = 14'd620;
   assign songFrequencyAmplitudes[1][295] =  8'd20;
   assign songFrequencies        [2][295] = 14'd186;
   assign songFrequencyAmplitudes[2][295] =  8'd13;
   //--
   assign songFrequencies        [0][296] = 14'd246;
   assign songFrequencyAmplitudes[0][296] =  8'd30;
   assign songFrequencies        [1][296] = 14'd620;
   assign songFrequencyAmplitudes[1][296] =  8'd21;
   assign songFrequencies        [2][296] = 14'd120;
   assign songFrequencyAmplitudes[2][296] =  8'd13;
   //--
   assign songFrequencies        [0][297] = 14'd620;
   assign songFrequencyAmplitudes[0][297] =  8'd22;
   assign songFrequencies        [1][297] = 14'd246;
   assign songFrequencyAmplitudes[1][297] =  8'd19;
   assign songFrequencies        [2][297] = 14'd120;
   assign songFrequencyAmplitudes[2][297] =  8'd14;
   //--
   assign songFrequencies        [0][298] = 14'd620;
   assign songFrequencyAmplitudes[0][298] =  8'd21;
   assign songFrequencies        [1][298] = 14'd120;
   assign songFrequencyAmplitudes[1][298] =  8'd14;
   assign songFrequencies        [2][298] = 14'd246;
   assign songFrequencyAmplitudes[2][298] =  8'd12;
   //--
   assign songFrequencies        [0][299] = 14'd620;
   assign songFrequencyAmplitudes[0][299] =  8'd19;
   assign songFrequencies        [1][299] = 14'd120;
   assign songFrequencyAmplitudes[1][299] =  8'd13;
   assign songFrequencies        [2][299] = 14'd246;
   assign songFrequencyAmplitudes[2][299] =  8'd12;
   //--
   assign songFrequencies        [0][300] = 14'd620;
   assign songFrequencyAmplitudes[0][300] =  8'd17;
   assign songFrequencies        [1][300] = 14'd246;
   assign songFrequencyAmplitudes[1][300] =  8'd14;
   assign songFrequencies        [2][300] = 14'd433;
   assign songFrequencyAmplitudes[2][300] =  8'd11;
   //--
   assign songFrequencies        [0][301] = 14'd620;
   assign songFrequencyAmplitudes[0][301] =  8'd16;
   assign songFrequencies        [1][301] = 14'd246;
   assign songFrequencyAmplitudes[1][301] =  8'd15;
   assign songFrequencies        [2][301] = 14'd433;
   assign songFrequencyAmplitudes[2][301] =  8'd11;
   //--
   assign songFrequencies        [0][302] = 14'd620;
   assign songFrequencyAmplitudes[0][302] =  8'd14;
   assign songFrequencies        [1][302] = 14'd246;
   assign songFrequencyAmplitudes[1][302] =  8'd14;
   assign songFrequencies        [2][302] = 14'd373;
   assign songFrequencyAmplitudes[2][302] =  8'd12;
   //--
   assign songFrequencies        [0][303] = 14'd373;
   assign songFrequencyAmplitudes[0][303] =  8'd14;
   assign songFrequencies        [1][303] = 14'd620;
   assign songFrequencyAmplitudes[1][303] =  8'd11;
   assign songFrequencies        [2][303] = 14'd246;
   assign songFrequencyAmplitudes[2][303] =  8'd11;
   //--
   assign songFrequencies        [0][304] = 14'd373;
   assign songFrequencyAmplitudes[0][304] =  8'd14;
   assign songFrequencies        [1][304] = 14'd366;
   assign songFrequencyAmplitudes[1][304] =  8'd11;
   assign songFrequencies        [2][304] = 14'd433;
   assign songFrequencyAmplitudes[2][304] =  8'd10;
   //--
   assign songFrequencies        [0][305] = 14'd373;
   assign songFrequencyAmplitudes[0][305] =  8'd15;
   assign songFrequencies        [1][305] = 14'd366;
   assign songFrequencyAmplitudes[1][305] =  8'd11;
   assign songFrequencies        [2][305] = 14'd433;
   assign songFrequencyAmplitudes[2][305] =  8'd9;
   //--
   assign songFrequencies        [0][306] = 14'd373;
   assign songFrequencyAmplitudes[0][306] =  8'd16;
   assign songFrequencies        [1][306] = 14'd366;
   assign songFrequencyAmplitudes[1][306] =  8'd11;
   assign songFrequencies        [2][306] = 14'd433;
   assign songFrequencyAmplitudes[2][306] =  8'd9;
   //--
   assign songFrequencies        [0][307] = 14'd373;
   assign songFrequencyAmplitudes[0][307] =  8'd16;
   assign songFrequencies        [1][307] = 14'd366;
   assign songFrequencyAmplitudes[1][307] =  8'd11;
   assign songFrequencies        [2][307] = 14'd433;
   assign songFrequencyAmplitudes[2][307] =  8'd8;
   //--
   assign songFrequencies        [0][308] = 14'd373;
   assign songFrequencyAmplitudes[0][308] =  8'd16;
   assign songFrequencies        [1][308] = 14'd366;
   assign songFrequencyAmplitudes[1][308] =  8'd10;
   assign songFrequencies        [2][308] = 14'd433;
   assign songFrequencyAmplitudes[2][308] =  8'd6;
   //--
   assign songFrequencies        [0][309] = 14'd373;
   assign songFrequencyAmplitudes[0][309] =  8'd15;
   assign songFrequencies        [1][309] = 14'd366;
   assign songFrequencyAmplitudes[1][309] =  8'd10;
   assign songFrequencies        [2][309] = 14'd246;
   assign songFrequencyAmplitudes[2][309] =  8'd8;
   //--
   assign songFrequencies        [0][310] = 14'd373;
   assign songFrequencyAmplitudes[0][310] =  8'd15;
   assign songFrequencies        [1][310] = 14'd366;
   assign songFrequencyAmplitudes[1][310] =  8'd9;
   assign songFrequencies        [2][310] = 14'd246;
   assign songFrequencyAmplitudes[2][310] =  8'd8;
   //--
   assign songFrequencies        [0][311] = 14'd373;
   assign songFrequencyAmplitudes[0][311] =  8'd14;
   assign songFrequencies        [1][311] = 14'd366;
   assign songFrequencyAmplitudes[1][311] =  8'd9;
   assign songFrequencies        [2][311] = 14'd246;
   assign songFrequencyAmplitudes[2][311] =  8'd8;
   //--
   assign songFrequencies        [0][312] = 14'd373;
   assign songFrequencyAmplitudes[0][312] =  8'd13;
   assign songFrequencies        [1][312] = 14'd366;
   assign songFrequencyAmplitudes[1][312] =  8'd9;
   assign songFrequencies        [2][312] = 14'd246;
   assign songFrequencyAmplitudes[2][312] =  8'd9;
   //--
   assign songFrequencies        [0][313] = 14'd373;
   assign songFrequencyAmplitudes[0][313] =  8'd13;
   assign songFrequencies        [1][313] = 14'd246;
   assign songFrequencyAmplitudes[1][313] =  8'd9;
   assign songFrequencies        [2][313] = 14'd366;
   assign songFrequencyAmplitudes[2][313] =  8'd8;
   //--
   assign songFrequencies        [0][314] = 14'd373;
   assign songFrequencyAmplitudes[0][314] =  8'd12;
   assign songFrequencies        [1][314] = 14'd366;
   assign songFrequencyAmplitudes[1][314] =  8'd8;
   assign songFrequencies        [2][314] = 14'd246;
   assign songFrequencyAmplitudes[2][314] =  8'd8;
   //--
   assign songFrequencies        [0][315] = 14'd373;
   assign songFrequencyAmplitudes[0][315] =  8'd11;
   assign songFrequencies        [1][315] = 14'd366;
   assign songFrequencyAmplitudes[1][315] =  8'd8;
   assign songFrequencies        [2][315] = 14'd620;
   assign songFrequencyAmplitudes[2][315] =  8'd7;
   //--
   assign songFrequencies        [0][316] = 14'd373;
   assign songFrequencyAmplitudes[0][316] =  8'd10;
   assign songFrequencies        [1][316] = 14'd620;
   assign songFrequencyAmplitudes[1][316] =  8'd7;
   assign songFrequencies        [2][316] = 14'd366;
   assign songFrequencyAmplitudes[2][316] =  8'd7;
   //--
   assign songFrequencies        [0][317] = 14'd373;
   assign songFrequencyAmplitudes[0][317] =  8'd10;
   assign songFrequencies        [1][317] = 14'd620;
   assign songFrequencyAmplitudes[1][317] =  8'd7;
   assign songFrequencies        [2][317] = 14'd366;
   assign songFrequencyAmplitudes[2][317] =  8'd7;
   //--
   assign songFrequencies        [0][318] = 14'd373;
   assign songFrequencyAmplitudes[0][318] =  8'd9;
   assign songFrequencies        [1][318] = 14'd620;
   assign songFrequencyAmplitudes[1][318] =  8'd8;
   assign songFrequencies        [2][318] = 14'd246;
   assign songFrequencyAmplitudes[2][318] =  8'd6;
   //--
   assign songFrequencies        [0][319] = 14'd373;
   assign songFrequencyAmplitudes[0][319] =  8'd8;
   assign songFrequencies        [1][319] = 14'd620;
   assign songFrequencyAmplitudes[1][319] =  8'd7;
   assign songFrequencies        [2][319] = 14'd246;
   assign songFrequencyAmplitudes[2][319] =  8'd6;
   //--
   assign songFrequencies        [0][320] = 14'd620;
   assign songFrequencyAmplitudes[0][320] =  8'd7;
   assign songFrequencies        [1][320] = 14'd373;
   assign songFrequencyAmplitudes[1][320] =  8'd6;
   assign songFrequencies        [2][320] = 14'd246;
   assign songFrequencyAmplitudes[2][320] =  8'd6;
   //--
   assign songFrequencies        [0][321] = 14'd620;
   assign songFrequencyAmplitudes[0][321] =  8'd7;
   assign songFrequencies        [1][321] = 14'd246;
   assign songFrequencyAmplitudes[1][321] =  8'd6;
   assign songFrequencies        [2][321] = 14'd373;
   assign songFrequencyAmplitudes[2][321] =  8'd5;
   //--
   assign songFrequencies        [0][322] = 14'd620;
   assign songFrequencyAmplitudes[0][322] =  8'd6;
   assign songFrequencies        [1][322] = 14'd246;
   assign songFrequencyAmplitudes[1][322] =  8'd6;
   assign songFrequencies        [2][322] = 14'd373;
   assign songFrequencyAmplitudes[2][322] =  8'd5;
   //--
   assign songFrequencies        [0][323] = 14'd246;
   assign songFrequencyAmplitudes[0][323] =  8'd6;
   assign songFrequencies        [1][323] = 14'd620;
   assign songFrequencyAmplitudes[1][323] =  8'd6;
   assign songFrequencies        [2][323] = 14'd433;
   assign songFrequencyAmplitudes[2][323] =  8'd4;
   //--
   assign songFrequencies        [0][324] = 14'd246;
   assign songFrequencyAmplitudes[0][324] =  8'd6;
   assign songFrequencies        [1][324] = 14'd620;
   assign songFrequencyAmplitudes[1][324] =  8'd5;
   assign songFrequencies        [2][324] = 14'd433;
   assign songFrequencyAmplitudes[2][324] =  8'd4;
   //--
   assign songFrequencies        [0][325] = 14'd246;
   assign songFrequencyAmplitudes[0][325] =  8'd5;
   assign songFrequencies        [1][325] = 14'd620;
   assign songFrequencyAmplitudes[1][325] =  8'd4;
   assign songFrequencies        [2][325] = 14'd433;
   assign songFrequencyAmplitudes[2][325] =  8'd4;
   //--
   assign songFrequencies        [0][326] = 14'd246;
   assign songFrequencyAmplitudes[0][326] =  8'd5;
   assign songFrequencies        [1][326] = 14'd433;
   assign songFrequencyAmplitudes[1][326] =  8'd4;
   assign songFrequencies        [2][326] = 14'd620;
   assign songFrequencyAmplitudes[2][326] =  8'd3;
   //--
   assign songFrequencies        [0][327] = 14'd246;
   assign songFrequencyAmplitudes[0][327] =  8'd4;
   assign songFrequencies        [1][327] = 14'd433;
   assign songFrequencyAmplitudes[1][327] =  8'd3;
   assign songFrequencies        [2][327] = 14'd620;
   assign songFrequencyAmplitudes[2][327] =  8'd2;
   //--
   assign songFrequencies        [0][328] = 14'd246;
   assign songFrequencyAmplitudes[0][328] =  8'd4;
   assign songFrequencies        [1][328] = 14'd433;
   assign songFrequencyAmplitudes[1][328] =  8'd3;
   assign songFrequencies        [2][328] = 14'd126;
   assign songFrequencyAmplitudes[2][328] =  8'd2;
   //--
   assign songFrequencies        [0][329] = 14'd246;
   assign songFrequencyAmplitudes[0][329] =  8'd4;
   assign songFrequencies        [1][329] = 14'd433;
   assign songFrequencyAmplitudes[1][329] =  8'd3;
   assign songFrequencies        [2][329] = 14'd126;
   assign songFrequencyAmplitudes[2][329] =  8'd2;
   //--
   assign songFrequencies        [0][330] = 14'd246;
   assign songFrequencyAmplitudes[0][330] =  8'd4;
   assign songFrequencies        [1][330] = 14'd433;
   assign songFrequencyAmplitudes[1][330] =  8'd3;
   assign songFrequencies        [2][330] = 14'd120;
   assign songFrequencyAmplitudes[2][330] =  8'd2;
   //--
   assign songFrequencies        [0][331] = 14'd253;
   assign songFrequencyAmplitudes[0][331] =  8'd6;
   assign songFrequencies        [1][331] = 14'd613;
   assign songFrequencyAmplitudes[1][331] =  8'd5;
   assign songFrequencies        [2][331] = 14'd260;
   assign songFrequencyAmplitudes[2][331] =  8'd5;
   //--
   assign songFrequencies        [0][332] = 14'd246;
   assign songFrequencyAmplitudes[0][332] =  8'd18;
   assign songFrequencies        [1][332] = 14'd253;
   assign songFrequencyAmplitudes[1][332] =  8'd12;
   assign songFrequencies        [2][332] = 14'd620;
   assign songFrequencyAmplitudes[2][332] =  8'd11;
   //--
   assign songFrequencies        [0][333] = 14'd246;
   assign songFrequencyAmplitudes[0][333] =  8'd30;
   assign songFrequencies        [1][333] = 14'd613;
   assign songFrequencyAmplitudes[1][333] =  8'd15;
   assign songFrequencies        [2][333] = 14'd626;
   assign songFrequencyAmplitudes[2][333] =  8'd11;
   //--
   assign songFrequencies        [0][334] = 14'd246;
   assign songFrequencyAmplitudes[0][334] =  8'd35;
   assign songFrequencies        [1][334] = 14'd626;
   assign songFrequencyAmplitudes[1][334] =  8'd20;
   assign songFrequencies        [2][334] = 14'd613;
   assign songFrequencyAmplitudes[2][334] =  8'd15;
   //--
   assign songFrequencies        [0][335] = 14'd246;
   assign songFrequencyAmplitudes[0][335] =  8'd29;
   assign songFrequencies        [1][335] = 14'd620;
   assign songFrequencyAmplitudes[1][335] =  8'd29;
   assign songFrequencies        [2][335] = 14'd433;
   assign songFrequencyAmplitudes[2][335] =  8'd11;
   //--
   assign songFrequencies        [0][336] = 14'd620;
   assign songFrequencyAmplitudes[0][336] =  8'd25;
   assign songFrequencies        [1][336] = 14'd246;
   assign songFrequencyAmplitudes[1][336] =  8'd19;
   assign songFrequencies        [2][336] = 14'd120;
   assign songFrequencyAmplitudes[2][336] =  8'd12;
   //--
   assign songFrequencies        [0][337] = 14'd120;
   assign songFrequencyAmplitudes[0][337] =  8'd14;
   assign songFrequencies        [1][337] = 14'd246;
   assign songFrequencyAmplitudes[1][337] =  8'd12;
   assign songFrequencies        [2][337] = 14'd433;
   assign songFrequencyAmplitudes[2][337] =  8'd11;
   //--
   assign songFrequencies        [0][338] = 14'd306;
   assign songFrequencyAmplitudes[0][338] =  8'd18;
   assign songFrequencies        [1][338] = 14'd120;
   assign songFrequencyAmplitudes[1][338] =  8'd13;
   assign songFrequencies        [2][338] = 14'd620;
   assign songFrequencyAmplitudes[2][338] =  8'd12;
   //--
   assign songFrequencies        [0][339] = 14'd306;
   assign songFrequencyAmplitudes[0][339] =  8'd28;
   assign songFrequencies        [1][339] = 14'd620;
   assign songFrequencyAmplitudes[1][339] =  8'd26;
   assign songFrequencies        [2][339] = 14'd313;
   assign songFrequencyAmplitudes[2][339] =  8'd24;
   //--
   assign songFrequencies        [0][340] = 14'd313;
   assign songFrequencyAmplitudes[0][340] =  8'd34;
   assign songFrequencies        [1][340] = 14'd620;
   assign songFrequencyAmplitudes[1][340] =  8'd29;
   assign songFrequencies        [2][340] = 14'd306;
   assign songFrequencyAmplitudes[2][340] =  8'd29;
   //--
   assign songFrequencies        [0][341] = 14'd313;
   assign songFrequencyAmplitudes[0][341] =  8'd37;
   assign songFrequencies        [1][341] = 14'd306;
   assign songFrequencyAmplitudes[1][341] =  8'd28;
   assign songFrequencies        [2][341] = 14'd620;
   assign songFrequencyAmplitudes[2][341] =  8'd21;
   //--
   assign songFrequencies        [0][342] = 14'd313;
   assign songFrequencyAmplitudes[0][342] =  8'd37;
   assign songFrequencies        [1][342] = 14'd306;
   assign songFrequencyAmplitudes[1][342] =  8'd26;
   assign songFrequencies        [2][342] = 14'd153;
   assign songFrequencyAmplitudes[2][342] =  8'd18;
   //--
   assign songFrequencies        [0][343] = 14'd313;
   assign songFrequencyAmplitudes[0][343] =  8'd37;
   assign songFrequencies        [1][343] = 14'd306;
   assign songFrequencyAmplitudes[1][343] =  8'd21;
   assign songFrequencies        [2][343] = 14'd153;
   assign songFrequencyAmplitudes[2][343] =  8'd17;
   //--
   assign songFrequencies        [0][344] = 14'd313;
   assign songFrequencyAmplitudes[0][344] =  8'd35;
   assign songFrequencies        [1][344] = 14'd366;
   assign songFrequencyAmplitudes[1][344] =  8'd16;
   assign songFrequencies        [2][344] = 14'd620;
   assign songFrequencyAmplitudes[2][344] =  8'd16;
   //--
   assign songFrequencies        [0][345] = 14'd313;
   assign songFrequencyAmplitudes[0][345] =  8'd30;
   assign songFrequencies        [1][345] = 14'd366;
   assign songFrequencyAmplitudes[1][345] =  8'd25;
   assign songFrequencies        [2][345] = 14'd186;
   assign songFrequencyAmplitudes[2][345] =  8'd15;
   //--
   assign songFrequencies        [0][346] = 14'd186;
   assign songFrequencyAmplitudes[0][346] =  8'd28;
   assign songFrequencies        [1][346] = 14'd313;
   assign songFrequencyAmplitudes[1][346] =  8'd27;
   assign songFrequencies        [2][346] = 14'd366;
   assign songFrequencyAmplitudes[2][346] =  8'd27;
   //--
   assign songFrequencies        [0][347] = 14'd186;
   assign songFrequencyAmplitudes[0][347] =  8'd31;
   assign songFrequencies        [1][347] = 14'd373;
   assign songFrequencyAmplitudes[1][347] =  8'd26;
   assign songFrequencies        [2][347] = 14'd366;
   assign songFrequencyAmplitudes[2][347] =  8'd25;
   //--
   assign songFrequencies        [0][348] = 14'd186;
   assign songFrequencyAmplitudes[0][348] =  8'd29;
   assign songFrequencies        [1][348] = 14'd366;
   assign songFrequencyAmplitudes[1][348] =  8'd25;
   assign songFrequencies        [2][348] = 14'd313;
   assign songFrequencyAmplitudes[2][348] =  8'd25;
   //--
   assign songFrequencies        [0][349] = 14'd186;
   assign songFrequencyAmplitudes[0][349] =  8'd26;
   assign songFrequencies        [1][349] = 14'd313;
   assign songFrequencyAmplitudes[1][349] =  8'd25;
   assign songFrequencies        [2][349] = 14'd366;
   assign songFrequencyAmplitudes[2][349] =  8'd19;
   //--
   assign songFrequencies        [0][350] = 14'd313;
   assign songFrequencyAmplitudes[0][350] =  8'd26;
   assign songFrequencies        [1][350] = 14'd186;
   assign songFrequencyAmplitudes[1][350] =  8'd25;
   assign songFrequencies        [2][350] = 14'd306;
   assign songFrequencyAmplitudes[2][350] =  8'd14;
   //--
   assign songFrequencies        [0][351] = 14'd313;
   assign songFrequencyAmplitudes[0][351] =  8'd26;
   assign songFrequencies        [1][351] = 14'd186;
   assign songFrequencyAmplitudes[1][351] =  8'd23;
   assign songFrequencies        [2][351] = 14'd306;
   assign songFrequencyAmplitudes[2][351] =  8'd14;
   //--
   assign songFrequencies        [0][352] = 14'd186;
   assign songFrequencyAmplitudes[0][352] =  8'd25;
   assign songFrequencies        [1][352] = 14'd313;
   assign songFrequencyAmplitudes[1][352] =  8'd23;
   assign songFrequencies        [2][352] = 14'd306;
   assign songFrequencyAmplitudes[2][352] =  8'd13;
   //--
   assign songFrequencies        [0][353] = 14'd186;
   assign songFrequencyAmplitudes[0][353] =  8'd26;
   assign songFrequencies        [1][353] = 14'd313;
   assign songFrequencyAmplitudes[1][353] =  8'd21;
   assign songFrequencies        [2][353] = 14'd366;
   assign songFrequencyAmplitudes[2][353] =  8'd14;
   //--
   assign songFrequencies        [0][354] = 14'd186;
   assign songFrequencyAmplitudes[0][354] =  8'd23;
   assign songFrequencies        [1][354] = 14'd313;
   assign songFrequencyAmplitudes[1][354] =  8'd21;
   assign songFrequencies        [2][354] = 14'd366;
   assign songFrequencyAmplitudes[2][354] =  8'd19;
   //--
   assign songFrequencies        [0][355] = 14'd180;
   assign songFrequencyAmplitudes[0][355] =  8'd26;
   assign songFrequencies        [1][355] = 14'd186;
   assign songFrequencyAmplitudes[1][355] =  8'd25;
   assign songFrequencies        [2][355] = 14'd366;
   assign songFrequencyAmplitudes[2][355] =  8'd22;
   //--
   assign songFrequencies        [0][356] = 14'd186;
   assign songFrequencyAmplitudes[0][356] =  8'd41;
   assign songFrequencies        [1][356] = 14'd180;
   assign songFrequencyAmplitudes[1][356] =  8'd21;
   assign songFrequencies        [2][356] = 14'd366;
   assign songFrequencyAmplitudes[2][356] =  8'd20;
   //--
   assign songFrequencies        [0][357] = 14'd186;
   assign songFrequencyAmplitudes[0][357] =  8'd49;
   assign songFrequencies        [1][357] = 14'd366;
   assign songFrequencyAmplitudes[1][357] =  8'd20;
   assign songFrequencies        [2][357] = 14'd180;
   assign songFrequencyAmplitudes[2][357] =  8'd20;
   //--
   assign songFrequencies        [0][358] = 14'd186;
   assign songFrequencyAmplitudes[0][358] =  8'd50;
   assign songFrequencies        [1][358] = 14'd740;
   assign songFrequencyAmplitudes[1][358] =  8'd27;
   assign songFrequencies        [2][358] = 14'd746;
   assign songFrequencyAmplitudes[2][358] =  8'd22;
   //--
   assign songFrequencies        [0][359] = 14'd740;
   assign songFrequencyAmplitudes[0][359] =  8'd52;
   assign songFrequencies        [1][359] = 14'd186;
   assign songFrequencyAmplitudes[1][359] =  8'd47;
   assign songFrequencies        [2][359] = 14'd746;
   assign songFrequencyAmplitudes[2][359] =  8'd31;
   //--
   assign songFrequencies        [0][360] = 14'd740;
   assign songFrequencyAmplitudes[0][360] =  8'd64;
   assign songFrequencies        [1][360] = 14'd186;
   assign songFrequencyAmplitudes[1][360] =  8'd42;
   assign songFrequencies        [2][360] = 14'd746;
   assign songFrequencyAmplitudes[2][360] =  8'd24;
   //--
   assign songFrequencies        [0][361] = 14'd740;
   assign songFrequencyAmplitudes[0][361] =  8'd54;
   assign songFrequencies        [1][361] = 14'd186;
   assign songFrequencyAmplitudes[1][361] =  8'd42;
   assign songFrequencies        [2][361] = 14'd246;
   assign songFrequencyAmplitudes[2][361] =  8'd24;
   //--
   assign songFrequencies        [0][362] = 14'd186;
   assign songFrequencyAmplitudes[0][362] =  8'd42;
   assign songFrequencies        [1][362] = 14'd740;
   assign songFrequencyAmplitudes[1][362] =  8'd40;
   assign songFrequencies        [2][362] = 14'd246;
   assign songFrequencyAmplitudes[2][362] =  8'd25;
   //--
   assign songFrequencies        [0][363] = 14'd186;
   assign songFrequencyAmplitudes[0][363] =  8'd43;
   assign songFrequencies        [1][363] = 14'd740;
   assign songFrequencyAmplitudes[1][363] =  8'd35;
   assign songFrequencies        [2][363] = 14'd246;
   assign songFrequencyAmplitudes[2][363] =  8'd27;
   //--
   assign songFrequencies        [0][364] = 14'd186;
   assign songFrequencyAmplitudes[0][364] =  8'd41;
   assign songFrequencies        [1][364] = 14'd740;
   assign songFrequencyAmplitudes[1][364] =  8'd30;
   assign songFrequencies        [2][364] = 14'd246;
   assign songFrequencyAmplitudes[2][364] =  8'd22;
   //--
   assign songFrequencies        [0][365] = 14'd186;
   assign songFrequencyAmplitudes[0][365] =  8'd40;
   assign songFrequencies        [1][365] = 14'd740;
   assign songFrequencyAmplitudes[1][365] =  8'd23;
   assign songFrequencies        [2][365] = 14'd253;
   assign songFrequencyAmplitudes[2][365] =  8'd22;
   //--
   assign songFrequencies        [0][366] = 14'd186;
   assign songFrequencyAmplitudes[0][366] =  8'd36;
   assign songFrequencies        [1][366] = 14'd180;
   assign songFrequencyAmplitudes[1][366] =  8'd20;
   assign songFrequencies        [2][366] = 14'd126;
   assign songFrequencyAmplitudes[2][366] =  8'd19;
   //--
   assign songFrequencies        [0][367] = 14'd186;
   assign songFrequencyAmplitudes[0][367] =  8'd36;
   assign songFrequencies        [1][367] = 14'd246;
   assign songFrequencyAmplitudes[1][367] =  8'd23;
   assign songFrequencies        [2][367] = 14'd126;
   assign songFrequencyAmplitudes[2][367] =  8'd19;
   //--
   assign songFrequencies        [0][368] = 14'd186;
   assign songFrequencyAmplitudes[0][368] =  8'd37;
   assign songFrequencies        [1][368] = 14'd246;
   assign songFrequencyAmplitudes[1][368] =  8'd20;
   assign songFrequencies        [2][368] = 14'd120;
   assign songFrequencyAmplitudes[2][368] =  8'd19;
   //--
   assign songFrequencies        [0][369] = 14'd186;
   assign songFrequencyAmplitudes[0][369] =  8'd36;
   assign songFrequencies        [1][369] = 14'd180;
   assign songFrequencyAmplitudes[1][369] =  8'd18;
   assign songFrequencies        [2][369] = 14'd126;
   assign songFrequencyAmplitudes[2][369] =  8'd17;
   //--
   assign songFrequencies        [0][370] = 14'd186;
   assign songFrequencyAmplitudes[0][370] =  8'd36;
   assign songFrequencies        [1][370] = 14'd126;
   assign songFrequencyAmplitudes[1][370] =  8'd18;
   assign songFrequencies        [2][370] = 14'd180;
   assign songFrequencyAmplitudes[2][370] =  8'd17;
   //--
   assign songFrequencies        [0][371] = 14'd186;
   assign songFrequencyAmplitudes[0][371] =  8'd35;
   assign songFrequencies        [1][371] = 14'd660;
   assign songFrequencyAmplitudes[1][371] =  8'd23;
   assign songFrequencies        [2][371] = 14'd653;
   assign songFrequencyAmplitudes[2][371] =  8'd22;
   //--
   assign songFrequencies        [0][372] = 14'd660;
   assign songFrequencyAmplitudes[0][372] =  8'd45;
   assign songFrequencies        [1][372] = 14'd186;
   assign songFrequencyAmplitudes[1][372] =  8'd31;
   assign songFrequencies        [2][372] = 14'd326;
   assign songFrequencyAmplitudes[2][372] =  8'd22;
   //--
   assign songFrequencies        [0][373] = 14'd660;
   assign songFrequencyAmplitudes[0][373] =  8'd57;
   assign songFrequencies        [1][373] = 14'd326;
   assign songFrequencyAmplitudes[1][373] =  8'd25;
   assign songFrequencies        [2][373] = 14'd186;
   assign songFrequencyAmplitudes[2][373] =  8'd22;
   //--
   assign songFrequencies        [0][374] = 14'd660;
   assign songFrequencyAmplitudes[0][374] =  8'd44;
   assign songFrequencies        [1][374] = 14'd326;
   assign songFrequencyAmplitudes[1][374] =  8'd20;
   assign songFrequencies        [2][374] = 14'd80;
   assign songFrequencyAmplitudes[2][374] =  8'd17;
   //--
   assign songFrequencies        [0][375] = 14'd660;
   assign songFrequencyAmplitudes[0][375] =  8'd32;
   assign songFrequencies        [1][375] = 14'd166;
   assign songFrequencyAmplitudes[1][375] =  8'd17;
   assign songFrequencies        [2][375] = 14'd80;
   assign songFrequencyAmplitudes[2][375] =  8'd16;
   //--
   assign songFrequencies        [0][376] = 14'd660;
   assign songFrequencyAmplitudes[0][376] =  8'd29;
   assign songFrequencies        [1][376] = 14'd166;
   assign songFrequencyAmplitudes[1][376] =  8'd19;
   assign songFrequencies        [2][376] = 14'd80;
   assign songFrequencyAmplitudes[2][376] =  8'd14;
   //--
   assign songFrequencies        [0][377] = 14'd660;
   assign songFrequencyAmplitudes[0][377] =  8'd29;
   assign songFrequencies        [1][377] = 14'd166;
   assign songFrequencyAmplitudes[1][377] =  8'd16;
   assign songFrequencies        [2][377] = 14'd80;
   assign songFrequencyAmplitudes[2][377] =  8'd11;
   //--
   assign songFrequencies        [0][378] = 14'd660;
   assign songFrequencyAmplitudes[0][378] =  8'd27;
   assign songFrequencies        [1][378] = 14'd326;
   assign songFrequencyAmplitudes[1][378] =  8'd22;
   assign songFrequencies        [2][378] = 14'd160;
   assign songFrequencyAmplitudes[2][378] =  8'd17;
   //--
   assign songFrequencies        [0][379] = 14'd326;
   assign songFrequencyAmplitudes[0][379] =  8'd30;
   assign songFrequencies        [1][379] = 14'd660;
   assign songFrequencyAmplitudes[1][379] =  8'd27;
   assign songFrequencies        [2][379] = 14'd333;
   assign songFrequencyAmplitudes[2][379] =  8'd15;
   //--
   assign songFrequencies        [0][380] = 14'd326;
   assign songFrequencyAmplitudes[0][380] =  8'd29;
   assign songFrequencies        [1][380] = 14'd660;
   assign songFrequencyAmplitudes[1][380] =  8'd23;
   assign songFrequencies        [2][380] = 14'd166;
   assign songFrequencyAmplitudes[2][380] =  8'd17;
   //--
   assign songFrequencies        [0][381] = 14'd326;
   assign songFrequencyAmplitudes[0][381] =  8'd22;
   assign songFrequencies        [1][381] = 14'd660;
   assign songFrequencyAmplitudes[1][381] =  8'd17;
   assign songFrequencies        [2][381] = 14'd493;
   assign songFrequencyAmplitudes[2][381] =  8'd13;
   //--
   assign songFrequencies        [0][382] = 14'd326;
   assign songFrequencyAmplitudes[0][382] =  8'd17;
   assign songFrequencies        [1][382] = 14'd493;
   assign songFrequencyAmplitudes[1][382] =  8'd12;
   assign songFrequencies        [2][382] = 14'd660;
   assign songFrequencyAmplitudes[2][382] =  8'd10;
   //--
   assign songFrequencies        [0][383] = 14'd326;
   assign songFrequencyAmplitudes[0][383] =  8'd13;
   assign songFrequencies        [1][383] = 14'd493;
   assign songFrequencyAmplitudes[1][383] =  8'd11;
   assign songFrequencies        [2][383] = 14'd166;
   assign songFrequencyAmplitudes[2][383] =  8'd9;
   //--
   assign songFrequencies        [0][384] = 14'd166;
   assign songFrequencyAmplitudes[0][384] =  8'd13;
   assign songFrequencies        [1][384] = 14'd326;
   assign songFrequencyAmplitudes[1][384] =  8'd12;
   assign songFrequencies        [2][384] = 14'd413;
   assign songFrequencyAmplitudes[2][384] =  8'd11;
   //--
   assign songFrequencies        [0][385] = 14'd413;
   assign songFrequencyAmplitudes[0][385] =  8'd28;
   assign songFrequencies        [1][385] = 14'd420;
   assign songFrequencyAmplitudes[1][385] =  8'd26;
   assign songFrequencies        [2][385] = 14'd620;
   assign songFrequencyAmplitudes[2][385] =  8'd14;
   //--
   assign songFrequencies        [0][386] = 14'd413;
   assign songFrequencyAmplitudes[0][386] =  8'd44;
   assign songFrequencies        [1][386] = 14'd420;
   assign songFrequencyAmplitudes[1][386] =  8'd26;
   assign songFrequencies        [2][386] = 14'd206;
   assign songFrequencyAmplitudes[2][386] =  8'd19;
   //--
   assign songFrequencies        [0][387] = 14'd413;
   assign songFrequencyAmplitudes[0][387] =  8'd48;
   assign songFrequencies        [1][387] = 14'd420;
   assign songFrequencyAmplitudes[1][387] =  8'd21;
   assign songFrequencies        [2][387] = 14'd206;
   assign songFrequencyAmplitudes[2][387] =  8'd21;
   //--
   assign songFrequencies        [0][388] = 14'd413;
   assign songFrequencyAmplitudes[0][388] =  8'd41;
   assign songFrequencies        [1][388] = 14'd206;
   assign songFrequencyAmplitudes[1][388] =  8'd22;
   assign songFrequencies        [2][388] = 14'd420;
   assign songFrequencyAmplitudes[2][388] =  8'd19;
   //--
   assign songFrequencies        [0][389] = 14'd413;
   assign songFrequencyAmplitudes[0][389] =  8'd36;
   assign songFrequencies        [1][389] = 14'd206;
   assign songFrequencyAmplitudes[1][389] =  8'd22;
   assign songFrequencies        [2][389] = 14'd620;
   assign songFrequencyAmplitudes[2][389] =  8'd16;
   //--
   assign songFrequencies        [0][390] = 14'd413;
   assign songFrequencyAmplitudes[0][390] =  8'd32;
   assign songFrequencies        [1][390] = 14'd206;
   assign songFrequencyAmplitudes[1][390] =  8'd23;
   assign songFrequencies        [2][390] = 14'd620;
   assign songFrequencyAmplitudes[2][390] =  8'd16;
   //--
   assign songFrequencies        [0][391] = 14'd413;
   assign songFrequencyAmplitudes[0][391] =  8'd29;
   assign songFrequencies        [1][391] = 14'd206;
   assign songFrequencyAmplitudes[1][391] =  8'd22;
   assign songFrequencies        [2][391] = 14'd620;
   assign songFrequencyAmplitudes[2][391] =  8'd18;
   //--
   assign songFrequencies        [0][392] = 14'd413;
   assign songFrequencyAmplitudes[0][392] =  8'd25;
   assign songFrequencies        [1][392] = 14'd620;
   assign songFrequencyAmplitudes[1][392] =  8'd21;
   assign songFrequencies        [2][392] = 14'd206;
   assign songFrequencyAmplitudes[2][392] =  8'd21;
   //--
   assign songFrequencies        [0][393] = 14'd413;
   assign songFrequencyAmplitudes[0][393] =  8'd20;
   assign songFrequencies        [1][393] = 14'd620;
   assign songFrequencyAmplitudes[1][393] =  8'd20;
   assign songFrequencies        [2][393] = 14'd206;
   assign songFrequencyAmplitudes[2][393] =  8'd19;
   //--
   assign songFrequencies        [0][394] = 14'd413;
   assign songFrequencyAmplitudes[0][394] =  8'd26;
   assign songFrequencies        [1][394] = 14'd206;
   assign songFrequencyAmplitudes[1][394] =  8'd26;
   assign songFrequencies        [2][394] = 14'd620;
   assign songFrequencyAmplitudes[2][394] =  8'd15;
   //--
   assign songFrequencies        [0][395] = 14'd413;
   assign songFrequencyAmplitudes[0][395] =  8'd39;
   assign songFrequencies        [1][395] = 14'd206;
   assign songFrequencyAmplitudes[1][395] =  8'd33;
   assign songFrequencies        [2][395] = 14'd420;
   assign songFrequencyAmplitudes[2][395] =  8'd24;
   //--
   assign songFrequencies        [0][396] = 14'd413;
   assign songFrequencyAmplitudes[0][396] =  8'd51;
   assign songFrequencies        [1][396] = 14'd206;
   assign songFrequencyAmplitudes[1][396] =  8'd41;
   assign songFrequencies        [2][396] = 14'd420;
   assign songFrequencyAmplitudes[2][396] =  8'd22;
   //--
   assign songFrequencies        [0][397] = 14'd413;
   assign songFrequencyAmplitudes[0][397] =  8'd49;
   assign songFrequencies        [1][397] = 14'd206;
   assign songFrequencyAmplitudes[1][397] =  8'd42;
   assign songFrequencies        [2][397] = 14'd420;
   assign songFrequencyAmplitudes[2][397] =  8'd17;
   //--
endmodule
