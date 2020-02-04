/*
SPI input through the ADS7868 ADC.  A full message is 12 bits, with 8 bits representing the data.
https://www.mouser.com/ProductDetail/Texas-Instruments/ADS7868IDBVR?qs=sGAEpiMZZMvTvDTV69d2Qt3F3KjDSYf5IFO8E4Bk9Lk%3D


We tell the ADC when to send a sample at sample rate of 10KHz. 
*/

module SPI_InputControllerDac( 
		input logic clock_50Mhz,
		input logic reset_n,

		input logic sendSample, //Signal tells the ADC to send signal.
		
		//--Configured as output.  These inputs connect directly to the GPIO pins.
		output logic input_SPI_SCLK, //Clock
		output logic input_SPI_CS_n, //Active low input.  
		input logic input_SPI_SDO,  //Serial data input.  Comes in MSB first.  Falling edge.
		
		output logic [7:0] outputSample, //Last generated sample
		output logic sampleReady //Sample is updated
		);
		
		//--GENERATE CLOCK SIGNAL
		wire CLK_240KHz ; //We need samples coming in every 10KHz, so the data clock is 10KHz * 12 * 2      Doubled for piece of mind.  
		ClockGenerator clockGenerator_240KHz (
			.inputClock(clock_50Mhz),
			.reset_n(reset_n),
			.outputClock(CLK_240KHz)
		);
		defparam	clockGenerator_240KHz.BitsNeeded = 13; //Must be able to count up to InputClockEdgesToCount.  
		defparam	clockGenerator_240KHz.InputClockEdgesToCount = 104;
		
		//--STATE INFORMATION
		reg [4:0]  currentState; //Current state in the state machine.  0 is idle, 1 is 4 0s, and 2 is sending the 12 bits.  Returns to 0 on completion.
		reg [15:0] counter; //Temporary use counter.  
		reg [7:0] workingSample;  //Holds the data as bits are shifted in.
		
		
		//SPI must be low while we are getting a new sample.
		assign input_SPI_CS_n = (currentState == 0);
		assign input_SPI_SCLK = CLK_240KHz;
		
		always_ff@(negedge CLK_240KHz, negedge reset_n) begin
			//--RESET 
			if (reset_n == 0)begin
				workingSample <= 0;
				currentState <= 0;
				counter <= 0;
				sampleReady <=0;
				outputSample <=0;
			end
			//--STATE 0 : Look to start
			else if (currentState == 0) begin
				workingSample <= 0; 
				counter <= 0;
				sampleReady <= 0;
				if (sendSample == 1) begin
					currentState <= 1;
				end
			end
			//--STATE 1 : Sample data pin
			else if (currentState == 1) begin
				//If we have counted all the neccesary bits, end
				if (counter >= 11) begin
					currentState <= 0;
					outputSample <= workingSample;
					sampleReady <= 1;
				end
				else begin //Increment counter, shift the working sample 1 bit left, and fill the new rightmost bit with the data pin.
					counter <= counter + 1;
					workingSample <= (workingSample << 1 )+ 1;
					//The ADC selected has 4 '0' bits.  This technically records them, but these are overwritten by the actual data pins.  Basically we don't care about the first 4 data pins.
				end
			end //State or Reset
		end //Clock edge

endmodule