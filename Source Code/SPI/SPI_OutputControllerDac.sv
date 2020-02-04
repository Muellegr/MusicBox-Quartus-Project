/*

Must send 16 bits.  Only 12 of those bits are used to set the output value.  
 X  X  0  0  D  D  D  D  D  D  D  D  D  D  D  D
15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0

The two 0s configure the state : Basically tell it the system is on.


HOW TO USE
	Give 50Mhz clock, reset_n
	Give physical hardware output pins for SPI
	
	inputSample is 12 bits you will want to send.
	sendSample_n is active low signal. When low it will send sample.
		InputSample can be changed while this is busy
		sendSample can go back high once this busy
		
*/
module SPI_OutputControllerDac( 
		input logic clock_50Mhz,
		input logic clock_1Khz,
		input logic reset_n,
		
		//--Configured as output.  These outputs connect directly to the GPIO pins.
		output logic output_SPI_SCLK,
		output logic output_SPI_SYNC_n,
		output logic output_SPI_DIN,
		
		//--Module interface
			//inputSample are the 12 bits you wish to send.
			//sendSample_n isan active low signal.  When it is low during 714kHz clock, it begins sending bits.
		input logic [11:0] inputSample, //12 bits that will be sent to the DAC
		input logic sendSample_n, //Active low signal.  If the system is not busy, it will begin sending the sample out.
		
		//While sending message, this signal is high.
		output logic isBusy,
		output logic transmitComplete //Goes high for 71Khz when this completes the signal
		);
		
		//--CLOCK GENERATOR
			//--The DAC will need to send at least 16 bits in 22050Hz.  
			//For safety, it will be designed to send 32 bits in the same time.
			// (50*10^6 / 2) * (1/x) = 22050*32
				//x = 35,    outputFreq :  714285 or 71.2Khz
		wire CLK_714Khz ;
		ClockGenerator clockGenerator_714Khz (
			.inputClock(clock_50Mhz),
			.reset_n(reset_n),
			.outputClock(CLK_714Khz)
		);
		defparam	clockGenerator_714Khz.BitsNeeded = 8; //Must be able to count up to InputClockEdgesToCount.  
		defparam	clockGenerator_714Khz.InputClockEdgesToCount = 35;
		//--
		
		reg [4:0]  currentState; //Current state in the state machine.  0 is idle, 1 is 4 0s, and 2 is sending the 12 bits.  Returns to 0 on completion.
		reg [15:0] counter; //Temporary use counter.  
		reg [11:0] writeSample; //When the state detects we are ready to write, this is set.  
		reg		   writeBit; //Individual bit we are writing

		//--Combinational logic tied into output pins
		assign output_SPI_SCLK = CLK_714Khz; //Tie output pin to this clock
		assign output_SPI_SYNC_n = (currentState == 0 ); //Sync is held high while we are in state 0.  
		assign output_SPI_DIN = writeBit * (currentState != 0); //Output current write bit only if we are not in idle.  
		assign isBusy = !(currentState == 0);
		
		always_ff@(negedge CLK_714Khz, negedge reset_n) begin
			if (reset_n == 0) begin
				currentState <= 0;
				writeBit <= 0;
				counter <= 0;
				transmitComplete <= 0;
			end
			//--Not sending data.  Wait until we get a request for information.
			else if (currentState == 0) begin
				transmitComplete <= 0; //Ensure it is set to 0 
				if (sendSample_n == 0) begin //Signal is active low
					writeSample <= inputSample; //Prevents inputSample causing problems if changed in middle of sending sample.
					currentState <= 1;
					writeBit <= 0; //Ensure writeBit is 0. 
				end
			end
			//--Beginning sending data.
				//First 2 bits are DO NOT CARE.
				//Next 2 bits are mode - 0 0
			else if (currentState == 1) begin
				transmitComplete <= 0;
				if (counter == 3) begin //This is the 4th zero
					counter <= 0;
					currentState <= 2;
					//This takes 1 clock cycle to become the actual output.  
					writeBit <= writeSample[11];
					writeSample <= writeSample << 1; //Shift writeSample left by 1.
				end
				else begin
					counter <= counter + 1; //Continue waiting
				end
			end
			else if (currentState == 2) begin
				//Transmit complete : All bits sent
				if (counter == 11) begin
					transmitComplete <= 1;  //Set to 0 in next state
					counter <= 0;
					currentState <= 0;
					writeBit<=0;
					
				end
				//Continue sending bits
				else begin
					writeBit <= writeSample[11]; //As we shift sample left, the left-most bit (11) is next one to send out.
					writeSample <= writeSample << 1;
					
					transmitComplete <= 0;
					counter <= counter + 1;
				end
			end //States
		end //Always @ negedge 714k clock and reset_n
endmodule