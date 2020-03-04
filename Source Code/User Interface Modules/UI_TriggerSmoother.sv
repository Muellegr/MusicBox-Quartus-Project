/*

this is a input trigger smoother.  Kind of rough. 
Expects active low trigger.  
Outputs active low. 

Expects a 50Mhz clock.
*/

module UI_TriggerSmoother ( 
		input logic clock_50Mhz,
		input logic inputWire,
		input logic reset_n,
		
		output logic outputWire);
		
		reg [16:0] timeCounter;
		assign outputWire = !(timeCounter == 17'd50); //50000 is about 0.001s @ 50Mhz.  A tenth of this is not enough.
		
		
		always_ff @(posedge clock_50Mhz, negedge reset_n) begin
			//Has reset.  Reset counter.
			if (reset_n == 1'b0) begin
				 timeCounter = 17'd0;
			end
			else begin
			
				if (inputWire == 1'b0 ) begin
					if (timeCounter < 17'd50) begin
						timeCounter = timeCounter+17'd1;
					end
				end
				else begin
					timeCounter = 17'd0;
				end
			end

		end
endmodule