/*
Signal Generator - Creates a sine wave that has the supplied input frequency.
	Operates from 100Hz to 8000Hz.  
	
	outputSample is the current sine amplitude.
	
	
	This is a bit hardcoded to 128 total samples at a 32000 clock but can be changed by modifying some of the constants.

	TEST
		Test 128 values.
			64 values
			256 values.

		Should have no difference.

*/

module SignalGenerator_Square  ( 
		input logic CLK_32KHz,
		input logic reset_n,
		input logic[13:0] inputFrequency,
		output logic[7 : 0] outputSample
		);
		
	//  [Amount of bits -1] Name [AmountOfSamples]
	bit [7:0] squareWave[127:0];
	//Generated with python in \Python Support\SineValues\GenerateValues_Assign.py
always @ * begin
case(trueCounter)
     8'd0 : begin 
       outputSample = 8'b00000000;
   end
   8'd1 : begin 
       outputSample = 8'b00000000;
   end
   8'd2 : begin 
       outputSample = 8'b00000000;
   end
   8'd3 : begin 
       outputSample = 8'b00000000;
   end
   8'd4 : begin 
       outputSample = 8'b00000000;
   end
   8'd5 : begin 
       outputSample = 8'b00000000;
   end
   8'd6 : begin 
       outputSample = 8'b00000000;
   end
   8'd7 : begin 
       outputSample = 8'b00000000;
   end
   8'd8 : begin 
       outputSample = 8'b00000000;
   end
   8'd9 : begin 
       outputSample = 8'b00000000;
   end
   8'd10 : begin 
       outputSample = 8'b00000000;
   end
   8'd11 : begin 
       outputSample = 8'b00000000;
   end
   8'd12 : begin 
       outputSample = 8'b00000000;
   end
   8'd13 : begin 
       outputSample = 8'b00000000;
   end
   8'd14 : begin 
       outputSample = 8'b00000000;
   end
   8'd15 : begin 
       outputSample = 8'b00000000;
   end
   8'd16 : begin 
       outputSample = 8'b00000000;
   end
   8'd17 : begin 
       outputSample = 8'b00000000;
   end
   8'd18 : begin 
       outputSample = 8'b00000000;
   end
   8'd19 : begin 
       outputSample = 8'b00000000;
   end
   8'd20 : begin 
       outputSample = 8'b00000000;
   end
   8'd21 : begin 
       outputSample = 8'b00000000;
   end
   8'd22 : begin 
       outputSample = 8'b00000000;
   end
   8'd23 : begin 
       outputSample = 8'b00000000;
   end
   8'd24 : begin 
       outputSample = 8'b00000000;
   end
   8'd25 : begin 
       outputSample = 8'b00000000;
   end
   8'd26 : begin 
       outputSample = 8'b00000000;
   end
   8'd27 : begin 
       outputSample = 8'b00000000;
   end
   8'd28 : begin 
       outputSample = 8'b00000000;
   end
   8'd29 : begin 
       outputSample = 8'b00000000;
   end
   8'd30 : begin 
       outputSample = 8'b00000000;
   end
   8'd31 : begin 
       outputSample = 8'b00000000;
   end
   8'd32 : begin 
       outputSample = 8'b00000000;
   end
   8'd33 : begin 
       outputSample = 8'b00000000;
   end
   8'd34 : begin 
       outputSample = 8'b00000000;
   end
   8'd35 : begin 
       outputSample = 8'b00000000;
   end
   8'd36 : begin 
       outputSample = 8'b00000000;
   end
   8'd37 : begin 
       outputSample = 8'b00000000;
   end
   8'd38 : begin 
       outputSample = 8'b00000000;
   end
   8'd39 : begin 
       outputSample = 8'b00000000;
   end
   8'd40 : begin 
       outputSample = 8'b00000000;
   end
   8'd41 : begin 
       outputSample = 8'b00000000;
   end
   8'd42 : begin 
       outputSample = 8'b00000000;
   end
   8'd43 : begin 
       outputSample = 8'b00000000;
   end
   8'd44 : begin 
       outputSample = 8'b00000000;
   end
   8'd45 : begin 
       outputSample = 8'b00000000;
   end
   8'd46 : begin 
       outputSample = 8'b00000000;
   end
   8'd47 : begin 
       outputSample = 8'b00000000;
   end
   8'd48 : begin 
       outputSample = 8'b00000000;
   end
   8'd49 : begin 
       outputSample = 8'b00000000;
   end
   8'd50 : begin 
       outputSample = 8'b00000000;
   end
   8'd51 : begin 
       outputSample = 8'b00000000;
   end
   8'd52 : begin 
       outputSample = 8'b00000000;
   end
   8'd53 : begin 
       outputSample = 8'b00000000;
   end
   8'd54 : begin 
       outputSample = 8'b00000000;
   end
   8'd55 : begin 
       outputSample = 8'b00000000;
   end
   8'd56 : begin 
       outputSample = 8'b00000000;
   end
   8'd57 : begin 
       outputSample = 8'b00000000;
   end
   8'd58 : begin 
       outputSample = 8'b00000000;
   end
   8'd59 : begin 
       outputSample = 8'b00000000;
   end
   8'd60 : begin 
       outputSample = 8'b00000000;
   end
   8'd61 : begin 
       outputSample = 8'b00000000;
   end
   8'd62 : begin 
       outputSample = 8'b00000000;
   end
   8'd63 : begin 
       outputSample = 8'b00000000;
   end
   8'd64 : begin 
       outputSample = 8'b11111111;
   end
   8'd65 : begin 
       outputSample = 8'b11111111;
   end
   8'd66 : begin 
       outputSample = 8'b11111111;
   end
   8'd67 : begin 
       outputSample = 8'b11111111;
   end
   8'd68 : begin 
       outputSample = 8'b11111111;
   end
   8'd69 : begin 
       outputSample = 8'b11111111;
   end
   8'd70 : begin 
       outputSample = 8'b11111111;
   end
   8'd71 : begin 
       outputSample = 8'b11111111;
   end
   8'd72 : begin 
       outputSample = 8'b11111111;
   end
   8'd73 : begin 
       outputSample = 8'b11111111;
   end
   8'd74 : begin 
       outputSample = 8'b11111111;
   end
   8'd75 : begin 
       outputSample = 8'b11111111;
   end
   8'd76 : begin 
       outputSample = 8'b11111111;
   end
   8'd77 : begin 
       outputSample = 8'b11111111;
   end
   8'd78 : begin 
       outputSample = 8'b11111111;
   end
   8'd79 : begin 
       outputSample = 8'b11111111;
   end
   8'd80 : begin 
       outputSample = 8'b11111111;
   end
   8'd81 : begin 
       outputSample = 8'b11111111;
   end
   8'd82 : begin 
       outputSample = 8'b11111111;
   end
   8'd83 : begin 
       outputSample = 8'b11111111;
   end
   8'd84 : begin 
       outputSample = 8'b11111111;
   end
   8'd85 : begin 
       outputSample = 8'b11111111;
   end
   8'd86 : begin 
       outputSample = 8'b11111111;
   end
   8'd87 : begin 
       outputSample = 8'b11111111;
   end
   8'd88 : begin 
       outputSample = 8'b11111111;
   end
   8'd89 : begin 
       outputSample = 8'b11111111;
   end
   8'd90 : begin 
       outputSample = 8'b11111111;
   end
   8'd91 : begin 
       outputSample = 8'b11111111;
   end
   8'd92 : begin 
       outputSample = 8'b11111111;
   end
   8'd93 : begin 
       outputSample = 8'b11111111;
   end
   8'd94 : begin 
       outputSample = 8'b11111111;
   end
   8'd95 : begin 
       outputSample = 8'b11111111;
   end
   8'd96 : begin 
       outputSample = 8'b11111111;
   end
   8'd97 : begin 
       outputSample = 8'b11111111;
   end
   8'd98 : begin 
       outputSample = 8'b11111111;
   end
   8'd99 : begin 
       outputSample = 8'b11111111;
   end
   8'd100 : begin 
       outputSample = 8'b11111111;
   end
   8'd101 : begin 
       outputSample = 8'b11111111;
   end
   8'd102 : begin 
       outputSample = 8'b11111111;
   end
   8'd103 : begin 
       outputSample = 8'b11111111;
   end
   8'd104 : begin 
       outputSample = 8'b11111111;
   end
   8'd105 : begin 
       outputSample = 8'b11111111;
   end
   8'd106 : begin 
       outputSample = 8'b11111111;
   end
   8'd107 : begin 
       outputSample = 8'b11111111;
   end
   8'd108 : begin 
       outputSample = 8'b11111111;
   end
   8'd109 : begin 
       outputSample = 8'b11111111;
   end
   8'd110 : begin 
       outputSample = 8'b11111111;
   end
   8'd111 : begin 
       outputSample = 8'b11111111;
   end
   8'd112 : begin 
       outputSample = 8'b11111111;
   end
   8'd113 : begin 
       outputSample = 8'b11111111;
   end
   8'd114 : begin 
       outputSample = 8'b11111111;
   end
   8'd115 : begin 
       outputSample = 8'b11111111;
   end
   8'd116 : begin 
       outputSample = 8'b11111111;
   end
   8'd117 : begin 
       outputSample = 8'b11111111;
   end
   8'd118 : begin 
       outputSample = 8'b11111111;
   end
   8'd119 : begin 
       outputSample = 8'b11111111;
   end
   8'd120 : begin 
       outputSample = 8'b11111111;
   end
   8'd121 : begin 
       outputSample = 8'b11111111;
   end
   8'd122 : begin 
       outputSample = 8'b11111111;
   end
   8'd123 : begin 
       outputSample = 8'b11111111;
   end
   8'd124 : begin 
       outputSample = 8'b11111111;
   end
   8'd125 : begin 
       outputSample = 8'b11111111;
   end
   8'd126 : begin 
       outputSample = 8'b11111111;
   end
   8'd127 : begin 
       outputSample = 8'b11111111;
   end
   default : begin 
       outputSample = 8'd128;
   end

endcase
end

		
	//Will count up to 320000.
	reg [15 : 0] counter ; //16 bits max value is 64k ~
	always_ff @(posedge CLK_32KHz, negedge reset_n) begin
		if (reset_n == 1'b0)begin
			counter <= 1'b0;
		end
		else begin
			//Remember that it takes a clock cycle to update.
			// Beginning of clock, value is 31999.  So we add 1K to it.
			//We get index at 31999*1/255.
			//Next clock happens.
			//We are now 31999+1k.  This is too much, so we will reduce it.
				//But counter still does (31999+1k)/252.  
				//Also we only reduce it, didn't add to it.

			//If counter reaches top of index, it gets reduced by 32000 but keeps whatever it overshot by.  
			if (counter >= (16'd32000)) begin counter <= counter - (16'd32000 ) + inputFrequency; end
			//inputFrequency holds 14 bits, so we need 2 extra in front.
			else begin counter <= counter + inputFrequency;end//{ 2'b0, inputFrequency }; end
		end
	end

	wire [7:0] trueCounter ;
	//assign trueCounter = ((counter + (125)) * 1/252 ) ;   // 0.trueCounter == 1/252 
	//wire [9-1:-15] fp_number;
	assign trueCounter = ( ( counter % 16'd32000) * 1/250 ) ;   // 0.trueCounter == 1/252 
//	assign outputSample =squareWave[trueCounter];  
		
endmodule