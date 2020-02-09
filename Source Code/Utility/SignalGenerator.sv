//This module counts the rising edges of the Input Clock.  
//When this count reaches InputClockEdgesToCount, outputClock is flipped.  

/*
Have array with precalculated sine values.

Index value.
Every clock we might increment this.
When incremented, update sample.

*/

module SignalGenerator  ( 
		input logic inputClock,
		input logic reset_n,
		
		output logic[7 : 0] outputSample
		);
		
		// parameter reg preCalcSine =
		// {
		// 7'b10000110, 7'b10001101, 7'b10010011, 7'b10011001, 7'b10011111, 7'b10100101, 7'b10101011, 7'b10110001, 
		// 7'b10110111, 7'b10111100, 7'b11000010, 7'b11000111, 7'b11001100, 7'b11010001, 7'b11010110, 7'b11011011, 
		// 7'b11011111, 7'b11100011, 7'b11100111, 7'b11101010, 7'b11101110, 7'b11110001, 7'b11110100, 7'b11110110, 
		// 7'b11111001, 7'b11111010, 7'b11111100, 7'b11111110, 7'b11111111, 7'b11111111, 7'b11111111, 7'b11111111, 
		// 7'b11111111, 7'b11111111, 7'b11111111, 7'b11111110, 7'b11111100, 7'b11111010, 7'b11111001, 7'b11110110, 
		// 7'b11110100, 7'b11110001, 7'b11101110, 7'b11101010, 7'b11100111, 7'b11100011, 7'b11011111, 7'b11011011, 
		// 7'b11010110, 7'b11010001, 7'b11001100, 7'b11000111, 7'b11000010, 7'b10111100, 7'b10110111, 7'b10110001, 
		// 7'b10101011, 7'b10100101, 7'b10011111, 7'b10011001, 7'b10010011, 7'b10001101, 7'b10000110, 7'b10000000, 
		// 7'b01111010, 7'b01110011, 7'b01101101, 7'b01100111, 7'b01100001, 7'b01011011, 7'b01010101, 7'b01001111, 
		// 7'b01001001, 7'b01000100, 7'b00111110, 7'b00111001, 7'b00110100, 7'b00101111, 7'b00101010, 7'b00100101, 
		// 7'b00100001, 7'b00011101, 7'b00011001, 7'b00010110, 7'b00010010, 7'b00001111, 7'b00001100, 7'b00001010, 
		// 7'b00000111, 7'b00000110, 7'b00000100, 7'b00000010, 7'b00000001, 7'b00000001, 7'b00000000, 7'b00000000, 
		// 7'b00000000, 7'b00000001, 7'b00000001, 7'b00000010, 7'b00000100, 7'b00000110, 7'b00000111, 7'b00001010, 
		// 7'b00001100, 7'b00001111, 7'b00010010, 7'b00010110, 7'b00011001, 7'b00011101, 7'b00100001, 7'b00100101, 
		// 7'b00101010, 7'b00101111, 7'b00110100, 7'b00111001, 7'b00111110, 7'b01000100, 7'b01001001, 7'b01001111, 
		// 7'b01010101, 7'b01011011, 7'b01100001, 7'b01100111, 7'b01101101, 7'b01110011, 7'b01111010, 7'b10000000 
		// };
		
		// reg [7:0] byteShiftReg[127:0];
		// integer i;
		// initial begin
			// for (i=0;i<127;i=i+1) begin
				// //Extract each 16bit chunk in turn from the initial value parameter
				// //and use that as the initial value for this part of the shift register.
				// // Note the (9-i) bit is used because concatenation of the initial value places the first value in the most significant bits, and last value in the least significant bits.
				// byteShiftReg = preCalcSine[((127-i)*7)+:7];
			// end
		// end

		
		
		
		
		
		// localparam bit [7:0] preCalcSine[127:0] =
		// {
// 7'b10000110, 7'b10001101, 7'b10010011, 7'b10011001, 7'b10011111, 7'b10100101, 7'b10101011, 7'b10110001, 
// 7'b10110111, 7'b10111100, 7'b11000010, 7'b11000111, 7'b11001100, 7'b11010001, 7'b11010110, 7'b11011011, 
// 7'b11011111, 7'b11100011, 7'b11100111, 7'b11101010, 7'b11101110, 7'b11110001, 7'b11110100, 7'b11110110, 
// 7'b11111001, 7'b11111010, 7'b11111100, 7'b11111110, 7'b11111111, 7'b11111111, 7'b11111111, 7'b11111111, 
// 7'b11111111, 7'b11111111, 7'b11111111, 7'b11111110, 7'b11111100, 7'b11111010, 7'b11111001, 7'b11110110, 
// 7'b11110100, 7'b11110001, 7'b11101110, 7'b11101010, 7'b11100111, 7'b11100011, 7'b11011111, 7'b11011011, 
// 7'b11010110, 7'b11010001, 7'b11001100, 7'b11000111, 7'b11000010, 7'b10111100, 7'b10110111, 7'b10110001, 
// 7'b10101011, 7'b10100101, 7'b10011111, 7'b10011001, 7'b10010011, 7'b10001101, 7'b10000110, 7'b10000000, 
// 7'b01111010, 7'b01110011, 7'b01101101, 7'b01100111, 7'b01100001, 7'b01011011, 7'b01010101, 7'b01001111, 
// 7'b01001001, 7'b01000100, 7'b00111110, 7'b00111001, 7'b00110100, 7'b00101111, 7'b00101010, 7'b00100101, 
// 7'b00100001, 7'b00011101, 7'b00011001, 7'b00010110, 7'b00010010, 7'b00001111, 7'b00001100, 7'b00001010, 
// 7'b00000111, 7'b00000110, 7'b00000100, 7'b00000010, 7'b00000001, 7'b00000001, 7'b00000000, 7'b00000000, 
// 7'b00000000, 7'b00000001, 7'b00000001, 7'b00000010, 7'b00000100, 7'b00000110, 7'b00000111, 7'b00001010, 
// 7'b00001100, 7'b00001111, 7'b00010010, 7'b00010110, 7'b00011001, 7'b00011101, 7'b00100001, 7'b00100101, 
// 7'b00101010, 7'b00101111, 7'b00110100, 7'b00111001, 7'b00111110, 7'b01000100, 7'b01001001, 7'b01001111, 
// 7'b01010101, 7'b01011011, 7'b01100001, 7'b01100111, 7'b01101101, 7'b01110011, 7'b01111010, 7'b10000000 
// };
		// [valueSize] name [Amount];
	bit [7:0] preCalcSine[127:0];
	assign preCalcSine[0] = 8'b10000000;
	assign preCalcSine[1] = 8'b10000110;
	assign preCalcSine[2] = 8'b10001101;
	assign preCalcSine[3] = 8'b10010011;
	assign preCalcSine[4] = 8'b10011001;
	assign preCalcSine[5] = 8'b10011111;
	assign preCalcSine[6] = 8'b10100101;
	assign preCalcSine[7] = 8'b10101011;
	assign preCalcSine[8] = 8'b10110001;
	assign preCalcSine[9] = 8'b10110111;
	assign preCalcSine[10] = 8'b10111100;
	assign preCalcSine[11] = 8'b11000010;
	assign preCalcSine[12] = 8'b11000111;
	assign preCalcSine[13] = 8'b11001100;
	assign preCalcSine[14] = 8'b11010001;
	assign preCalcSine[15] = 8'b11010110;
	assign preCalcSine[16] = 8'b11011011;
	assign preCalcSine[17] = 8'b11011111;
	assign preCalcSine[18] = 8'b11100011;
	assign preCalcSine[19] = 8'b11100111;
	assign preCalcSine[20] = 8'b11101010;
	assign preCalcSine[21] = 8'b11101110;
	assign preCalcSine[22] = 8'b11110001;
	assign preCalcSine[23] = 8'b11110100;
	assign preCalcSine[24] = 8'b11110110;
	assign preCalcSine[25] = 8'b11111001;
	assign preCalcSine[26] = 8'b11111010;
	assign preCalcSine[27] = 8'b11111100;
	assign preCalcSine[28] = 8'b11111110;
	assign preCalcSine[29] = 8'b11111111;
	assign preCalcSine[30] = 8'b11111111;
	assign preCalcSine[31] = 8'b11111111;
	assign preCalcSine[32] = 8'b11111111;
	assign preCalcSine[33] = 8'b11111111;
	assign preCalcSine[34] = 8'b11111111;
	assign preCalcSine[35] = 8'b11111111;
	assign preCalcSine[36] = 8'b11111110;
	assign preCalcSine[37] = 8'b11111100;
	assign preCalcSine[38] = 8'b11111010;
	assign preCalcSine[39] = 8'b11111001;
	assign preCalcSine[40] = 8'b11110110;
	assign preCalcSine[41] = 8'b11110100;
	assign preCalcSine[42] = 8'b11110001;
	assign preCalcSine[43] = 8'b11101110;
	assign preCalcSine[44] = 8'b11101010;
	assign preCalcSine[45] = 8'b11100111;
	assign preCalcSine[46] = 8'b11100011;
	assign preCalcSine[47] = 8'b11011111;
	assign preCalcSine[48] = 8'b11011011;
	assign preCalcSine[49] = 8'b11010110;
	assign preCalcSine[50] = 8'b11010001;
	assign preCalcSine[51] = 8'b11001100;
	assign preCalcSine[52] = 8'b11000111;
	assign preCalcSine[53] = 8'b11000010;
	assign preCalcSine[54] = 8'b10111100;
	assign preCalcSine[55] = 8'b10110111;
	assign preCalcSine[56] = 8'b10110001;
	assign preCalcSine[57] = 8'b10101011;
	assign preCalcSine[58] = 8'b10100101;
	assign preCalcSine[59] = 8'b10011111;
	assign preCalcSine[60] = 8'b10011001;
	assign preCalcSine[61] = 8'b10010011;
	assign preCalcSine[62] = 8'b10001101;
	assign preCalcSine[63] = 8'b10000110;
	assign preCalcSine[64] = 8'b10000000;
	assign preCalcSine[65] = 8'b01111010;
	assign preCalcSine[66] = 8'b01110011;
	assign preCalcSine[67] = 8'b01101101;
	assign preCalcSine[68] = 8'b01100111;
	assign preCalcSine[69] = 8'b01100001;
	assign preCalcSine[70] = 8'b01011011;
	assign preCalcSine[71] = 8'b01010101;
	assign preCalcSine[72] = 8'b01001111;
	assign preCalcSine[73] = 8'b01001001;
	assign preCalcSine[74] = 8'b01000100;
	assign preCalcSine[75] = 8'b00111110;
	assign preCalcSine[76] = 8'b00111001;
	assign preCalcSine[77] = 8'b00110100;
	assign preCalcSine[78] = 8'b00101111;
	assign preCalcSine[79] = 8'b00101010;
	assign preCalcSine[80] = 8'b00100101;
	assign preCalcSine[81] = 8'b00100001;
	assign preCalcSine[82] = 8'b00011101;
	assign preCalcSine[83] = 8'b00011001;
	assign preCalcSine[84] = 8'b00010110;
	assign preCalcSine[85] = 8'b00010010;
	assign preCalcSine[86] = 8'b00001111;
	assign preCalcSine[87] = 8'b00001100;
	assign preCalcSine[88] = 8'b00001010;
	assign preCalcSine[89] = 8'b00000111;
	assign preCalcSine[90] = 8'b00000110;
	assign preCalcSine[91] = 8'b00000100;
	assign preCalcSine[92] = 8'b00000010;
	assign preCalcSine[93] = 8'b00000001;
	assign preCalcSine[94] = 8'b00000001;
	assign preCalcSine[95] = 8'b00000000;
	assign preCalcSine[96] = 8'b00000000;
	assign preCalcSine[97] = 8'b00000000;
	assign preCalcSine[98] = 8'b00000001;
	assign preCalcSine[99] = 8'b00000001;
	assign preCalcSine[100] = 8'b00000010;
	assign preCalcSine[101] = 8'b00000100;
	assign preCalcSine[102] = 8'b00000110;
	assign preCalcSine[103] = 8'b00000111;
	assign preCalcSine[104] = 8'b00001010;
	assign preCalcSine[105] = 8'b00001100;
	assign preCalcSine[106] = 8'b00001111;
	assign preCalcSine[107] = 8'b00010010;
	assign preCalcSine[108] = 8'b00010110;
	assign preCalcSine[109] = 8'b00011001;
	assign preCalcSine[110] = 8'b00011101;
	assign preCalcSine[111] = 8'b00100001;
	assign preCalcSine[112] = 8'b00100101;
	assign preCalcSine[113] = 8'b00101010;
	assign preCalcSine[114] = 8'b00101111;
	assign preCalcSine[115] = 8'b00110100;
	assign preCalcSine[116] = 8'b00111001;
	assign preCalcSine[117] = 8'b00111110;
	assign preCalcSine[118] = 8'b01000100;
	assign preCalcSine[119] = 8'b01001001;
	assign preCalcSine[120] = 8'b01001111;
	assign preCalcSine[121] = 8'b01010101;
	assign preCalcSine[122] = 8'b01011011;
	assign preCalcSine[123] = 8'b01100001;
	assign preCalcSine[124] = 8'b01100111;
	assign preCalcSine[125] = 8'b01101101;
	assign preCalcSine[126] = 8'b01110011;
	assign preCalcSine[127] = 8'b01111010;
		
				
		reg [8 : 0] counter ;
		always_ff @(posedge inputClock, negedge reset_n) begin
			if (reset_n == 0)begin
				counter <= 0;
			end
			else begin
				if (counter == 127) begin counter <= 0; end
				else begin counter <= counter + 1; end
			end
		end
		assign outputSample = preCalcSine[counter];
		
		Next step will be to have a regular value (frequency) that will update this.
endmodule