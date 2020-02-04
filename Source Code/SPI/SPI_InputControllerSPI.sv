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
		
		wire CLK_240KHz ; //We need samples coming in every 10KHz, so the data clock is 10KHz * 12 * 2      Doubled for piece of mind.  
		ClockGenerator clockGenerator_240KHz (
			.inputClock(clock_50Mhz),
			.reset_n(reset_n),
			.outputClock(CLK_240KHz)
		);
		defparam	clockGenerator_240KHz.BitsNeeded = 13; //Must be able to count up to InputClockEdgesToCount.  
		defparam	clockGenerator_240KHz.InputClockEdgesToCount = 104;
		
		reg [4:0]  currentState; //Current state in the state machine.  0 is idle, 1 is 4 0s, and 2 is sending the 12 bits.  Returns to 0 on completion.
		reg [15:0] counter; //Temporary use counter.  
		reg [7:0] workingSample;  //Holds the data as bits are shifted in.
		
		
		//SPI must be low while we are getting a new sample.
		assign input_SPI_CS_n = !(currentState == 0);
		assign input_SPI_SCLK = CLK_240KHz;
		
		always_ff@(negedge CLK_240KHz, negedge reset_n) begin
			if (reset_n == 0)begin
				workingSample <= 0;
				currentState <= 0;
				counter <= 0;
				sampleReady <=0;
			end
			if (currentState == 0) begin
				workingSample <= 0; 
				counter <= 0;
				sampleReady <= 0;
				if (sendSample == 1) begin
					currentState <= 1;
				end
			end
			if (currentState == 1) begin
				//If we have counted all the neccesary bits, end
				if (counter <= 11) begin
					currentState <= 0;
					//These happen on the next clock, when we are back to idle!
					outputSample <= workingSample << input_SPI_SDO;
					sampleReady <= 1;
					
				end
				else begin //We have not reached the end count
					counter <= counter + 1;
					workingSample <= workingSample << input_SPI_SDO;
				end
			end
			
		end
		
		
endmodule