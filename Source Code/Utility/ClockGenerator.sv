//This module counts the rising edges of the Input Clock.  
//When this count reaches InputClockEdgesToCount, outputClock is flipped.  

// (InputClock / 2) * (1 /InputClockEdgesToCount ) = OutputClock
//				SAME CLOCK : use 0//
//	Example : (50 Mhz / 2) * (1 / 25000) = 1Khz
//	Example : (1 Khz / 2) * (1 / 500) = 1hz

module ClockGenerator  #(parameter BitsNeeded = 15, InputClockEdgesToCount = 25000) ( 
		input logic inputClock,
		input logic reset_n,
		
		output logic outputClock
		);
		
		reg [BitsNeeded - 1 : 0] counter ;
		//reg a_outputClock;
		
		//assign outputClock = a_outputClock;
		
		//, negedge reset_n  Removed reset as it was causing timing problems.
		always_ff @(posedge inputClock, negedge reset_n) begin
			if (reset_n == 0 ) begin
				counter <= 0;
				outputClock <= 0;
			end
			else begin
				//If counter is sitting at the required amount of clock edges
				if (counter == InputClockEdgesToCount) begin
					counter <= 0;
					//Flip state
					outputClock <= !outputClock;
				end
				//Otherwhys simply increment
				else begin
					counter <= counter + 1;
				end
			end
		end
		
endmodule