/*
TODO
   need to test if its retrieving data on the correct clock
      connect to smooth switch and see if it increments properly with simple data file
      data file neds to be simple : all 1s, and hten all 0s.
      Check amplitude -> should be all 0s

      Do more complex work with this




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







SONG DATA FORMAT
   CHANNEL 0 
      Frequency
      Amplitude
   CHANNEL 1
      Frequency
      Amplitude
   CHANEL 2 
      Frequency
      Amplitude
   ...
   //---
   NEW SAMPLES

   So I want new samples every 0.01 seconds.
   That means I need to do  0.01 / 2 * channels in that time.  

   So custom clock i think for this
   



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
// const reg  songStepSize = 10'd10; //Time in ms between song update
// const  reg songIndexCount = 10'd100; //Number of array indexes to reach before this is complete

module MusicBoxState_PlaySong0 
   
   ( 
      input logic testSwitch,
		input logic testSwitch2,
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

   //--ROM integration
		output logic [15:0] romIndex, 
		output logic [15:0] romIndex_Max,
		input logic [15:0] romDataInput //Input data
		);

      assign debugString = romDataInput;//currentFrequency[0];//currentFrequency[0];// + currentFrequency[1] +  currentFrequency[2];
      parameter romIndexMax = 512;
      parameter channelCount = 6; //Make sure this is 2x the number of channels used

      assign romIndex_Max =romIndexMax;
      assign romIndex = currentIndex;

	//	assign debugString = {16'b0, milisecondCounter};


	//	reg [9:0] songIndexCounter ; //Current index value of the song.  This should always be clamped between 0 and songIndexCount.
		reg [9:0] milisecondCounter ; //Counts miliseconds.  Reset when reach songStepSize.

		reg outputActive;


   //Do clocks
   //1 clock updates multiple things.  
      reg [15:0] currentBaseIndex ; //This is the base index. 
      reg [15:0] currentBaseIndex_q;
      reg [15:0] currentIndex ; //This is the specific index we want from ROM before being offset
     // reg [7:0] currentChannel; //Harcoded
      reg [7:0] addressCounter; //Used for state machine
     // reg       currentChannel_f ; //Will frequency be on the next data ?


	 //Test switch controls the fast clock.  This should increment a bunch and update the frequency.
      always_ff @ (posedge testSwitch, negedge reset_n) begin
        
         if (reset_n == 0) begin
		 	currentBaseIndex_q <= 0;
            currentIndex <= 0;  
			currentFrequency <= 0;
            //currentChannel <= 0;
            addressCounter <= 0;
        //    currentChannel_f <= 1; //Frequency is always first to come in

         end
         //New values to update!
         else if (currentBaseIndex_q !=  currentBaseIndex ) begin
            //currentChannel <= 0; 
            //Start at 0 and work through all the current frequencies and amplitudes for this time period
			 currentBaseIndex_q <= currentBaseIndex;
            addressCounter <= 0;
         end


         else if (addressCounter < 7) begin
            //Acts as a statemachine of sorts
            addressCounter <= addressCounter + 1;
            case (addressCounter) 
               8'd0 : currentIndex <=  (currentBaseIndex * channelCount)  ; 
               8'd1 :   begin 
                           //Update current address on next clock cycle
                           currentIndex <= currentIndex + 1  ;  //Set to amplitude
                           currentFrequency[0] <= romDataInput ;
                        end
               8'd2 :   begin 
                           //Update current address on next clock cycle
                           currentIndex <= currentIndex + 1  ;   //Set to frequency
                           currentAmplitude[0] <= romDataInput ;
                        end 

                8'd3 :   begin 
                           //Update current address on next clock cycle
                            currentIndex <= currentIndex + 1  ;  //Set to amplitude
                           currentFrequency[0] <= romDataInput ;
                        end
               8'd4 :   begin 
                           //Update current address on next clock cycle
                            currentIndex <= currentIndex + 1  ;   //Set to frequency
                           currentAmplitude[1] <= romDataInput ;
                        end 

                8'd5 :   begin 
                           //Update current address on next clock cycle
                           currentIndex <= currentIndex + 1  ;   //Set to amplitude
                           currentFrequency[0] <= romDataInput ;
                        end
               8'd6 :   begin 
                           //Update current address on next clock cycle
                           currentIndex <= currentIndex + 1  ;   //Set to frequency
                           currentAmplitude[2] <= romDataInput ;
                        end 
            
               default : ; // No reason to expand upon this
            endcase


         end

        // end
      end




      
		always_ff @(posedge testSwitch2, negedge reset_n ) begin //clock_1Khz negedge reset_n 
			if (reset_n == 0 )begin // != 5'd1) begin
				//counter <= 16'b0;
				stateComplete <= 1'b0;
				currentBaseIndex <= 10'd0; 
				milisecondCounter <= 10'd0;
				outputActive <= 0;
			end
			else begin
				outputActive <= 1;
				if (currentBaseIndex == 184 -1) begin
					stateComplete <= 1'b1; 

				end
				//If we have not reached end of song
				else begin
					if ( milisecondCounter == 10'd0) begin
						milisecondCounter <= 0; //Set back to 0
						currentBaseIndex <= currentBaseIndex + 1;
					end
					else begin
						milisecondCounter <= milisecondCounter + 1;
					end
				end

		 	end //If correct state
		
		 end //Clock

	//--FREQUENCY GENERATORS
	assign audioAmplitudeOutput = (outputActive == 1'b1)? signalGeneratorOutput[0] + 
														               signalGeneratorOutput[1] + 
														               signalGeneratorOutput[2] : 8'd0; //Combine or equal 0 if output isn't active.
   wire [2:0][ 7:0] signalGeneratorOutput;
	wire [2:0][13:0] currentFrequency;
   wire [2:0][ 7:0] currentAmplitude;
	SignalGenerator signalGenerator_Sine0(
		.CLK_32KHz(clock_32Khz),
		.reset_n( reset_n),
		.inputFrequency(currentFrequency[0]),
      .inputAmplitude(currentAmplitude[0]),
		.outputSample(signalGeneratorOutput[0])
	);
	SignalGenerator signalGenerator_Sine1(
		.CLK_32KHz(clock_32Khz),
		.reset_n( reset_n),
		.inputFrequency(currentFrequency[1]),
      .inputAmplitude(currentAmplitude[1]),
		.outputSample(signalGeneratorOutput[1])
	);
	SignalGenerator signalGenerator_Sine2(
		.CLK_32KHz(clock_32Khz),
		.reset_n( reset_n),
		.inputFrequency(currentFrequency[2]),
      .inputAmplitude(currentAmplitude[2]),
		.outputSample(signalGeneratorOutput[2])
	);

	wire CLK_1Mhz ;
	ClockGenerator clockGenerator_1Mhz (
		.inputClock(max10Board_50MhzClock),
		.reset_n(systemReset_n),
		.outputClock(CLK_1Mhz)
	);
		defparam	clockGenerator_1Mhz.BitsNeeded = 6; //Must be able to count up to InputClockEdgesToCount.  
		defparam	clockGenerator_1Mhz.InputClockEdgesToCount = 25;


 endmodule
