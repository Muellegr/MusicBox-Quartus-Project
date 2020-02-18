/*
Signal Generator - Creates a sine wave that has the supplied input frequency.
	Operates from 100Hz to 8000Hz.  
	
	outputSample is the current sine amplitude.
	
	
	This is a bit hardcoded to 128 total samples at a 32000 clock but can be changed by modifying some of the constants.
*/

module SignalGenerator_Triangle  ( 
		input logic CLK_32KHz,
		input logic reset_n,
		input logic[13:0] inputFrequency,
		output logic[7 : 0] outputSample
		);
		
	//  [Amount of bits -1] Name [AmountOfSamples]
	bit [7:0] preCalcTriangle[127:0];
	//Generated with python in \Python Support\SineValues\GenerateValues_Assign.py
	assign preCalcTriangle[0] = 8'b00000000;
	assign preCalcTriangle[1] = 8'b00000100;
	assign preCalcTriangle[2] = 8'b00001000;
	assign preCalcTriangle[3] = 8'b00001100;
	assign preCalcTriangle[4] = 8'b00010000;
	assign preCalcTriangle[5] = 8'b00010100;
	assign preCalcTriangle[6] = 8'b00011000;
	assign preCalcTriangle[7] = 8'b00011100;
	assign preCalcTriangle[8] = 8'b00100000;
	assign preCalcTriangle[9] = 8'b00100100;
	assign preCalcTriangle[10] = 8'b00101000;
	assign preCalcTriangle[11] = 8'b00101100;
	assign preCalcTriangle[12] = 8'b00110000;
	assign preCalcTriangle[13] = 8'b00110100;
	assign preCalcTriangle[14] = 8'b00111000;
	assign preCalcTriangle[15] = 8'b00111100;
	assign preCalcTriangle[16] = 8'b01000000;
	assign preCalcTriangle[17] = 8'b01000100;
	assign preCalcTriangle[18] = 8'b01001000;
	assign preCalcTriangle[19] = 8'b01001100;
	assign preCalcTriangle[20] = 8'b01010000;
	assign preCalcTriangle[21] = 8'b01010100;
	assign preCalcTriangle[22] = 8'b01011000;
	assign preCalcTriangle[23] = 8'b01011100;
	assign preCalcTriangle[24] = 8'b01100000;
	assign preCalcTriangle[25] = 8'b01100100;
	assign preCalcTriangle[26] = 8'b01101000;
	assign preCalcTriangle[27] = 8'b01101100;
	assign preCalcTriangle[28] = 8'b01110000;
	assign preCalcTriangle[29] = 8'b01110100;
	assign preCalcTriangle[30] = 8'b01111000;
	assign preCalcTriangle[31] = 8'b01111100;
	assign preCalcTriangle[32] = 8'b10000000;
	assign preCalcTriangle[33] = 8'b10000100;
	assign preCalcTriangle[34] = 8'b10001000;
	assign preCalcTriangle[35] = 8'b10001100;
	assign preCalcTriangle[36] = 8'b10010000;
	assign preCalcTriangle[37] = 8'b10010100;
	assign preCalcTriangle[38] = 8'b10011000;
	assign preCalcTriangle[39] = 8'b10011100;
	assign preCalcTriangle[40] = 8'b10100000;
	assign preCalcTriangle[41] = 8'b10100100;
	assign preCalcTriangle[42] = 8'b10101000;
	assign preCalcTriangle[43] = 8'b10101100;
	assign preCalcTriangle[44] = 8'b10110000;
	assign preCalcTriangle[45] = 8'b10110100;
	assign preCalcTriangle[46] = 8'b10111000;
	assign preCalcTriangle[47] = 8'b10111100;
	assign preCalcTriangle[48] = 8'b11000000;
	assign preCalcTriangle[49] = 8'b11000100;
	assign preCalcTriangle[50] = 8'b11001000;
	assign preCalcTriangle[51] = 8'b11001100;
	assign preCalcTriangle[52] = 8'b11010000;
	assign preCalcTriangle[53] = 8'b11010100;
	assign preCalcTriangle[54] = 8'b11011000;
	assign preCalcTriangle[55] = 8'b11011100;
	assign preCalcTriangle[56] = 8'b11100000;
	assign preCalcTriangle[57] = 8'b11100100;
	assign preCalcTriangle[58] = 8'b11101000;
	assign preCalcTriangle[59] = 8'b11101100;
	assign preCalcTriangle[60] = 8'b11110000;
	assign preCalcTriangle[61] = 8'b11110100;
	assign preCalcTriangle[62] = 8'b11111000;
	assign preCalcTriangle[63] = 8'b11111100;
	assign preCalcTriangle[64] = 8'b11111111;
	assign preCalcTriangle[65] = 8'b11111100;
	assign preCalcTriangle[66] = 8'b11111000;
	assign preCalcTriangle[67] = 8'b11110100;
	assign preCalcTriangle[68] = 8'b11110000;
	assign preCalcTriangle[69] = 8'b11101100;
	assign preCalcTriangle[70] = 8'b11101000;
	assign preCalcTriangle[71] = 8'b11100100;
	assign preCalcTriangle[72] = 8'b11100000;
	assign preCalcTriangle[73] = 8'b11011100;
	assign preCalcTriangle[74] = 8'b11011000;
	assign preCalcTriangle[75] = 8'b11010100;
	assign preCalcTriangle[76] = 8'b11010000;
	assign preCalcTriangle[77] = 8'b11001100;
	assign preCalcTriangle[78] = 8'b11001000;
	assign preCalcTriangle[79] = 8'b11000100;
	assign preCalcTriangle[80] = 8'b11000000;
	assign preCalcTriangle[81] = 8'b10111100;
	assign preCalcTriangle[82] = 8'b10111000;
	assign preCalcTriangle[83] = 8'b10110100;
	assign preCalcTriangle[84] = 8'b10110000;
	assign preCalcTriangle[85] = 8'b10101100;
	assign preCalcTriangle[86] = 8'b10101000;
	assign preCalcTriangle[87] = 8'b10100100;
	assign preCalcTriangle[88] = 8'b10100000;
	assign preCalcTriangle[89] = 8'b10011100;
	assign preCalcTriangle[90] = 8'b10011000;
	assign preCalcTriangle[91] = 8'b10010100;
	assign preCalcTriangle[92] = 8'b10010000;
	assign preCalcTriangle[93] = 8'b10001100;
	assign preCalcTriangle[94] = 8'b10001000;
	assign preCalcTriangle[95] = 8'b10000100;
	assign preCalcTriangle[96] = 8'b10000000;
	assign preCalcTriangle[97] = 8'b01111100;
	assign preCalcTriangle[98] = 8'b01111000;
	assign preCalcTriangle[99] = 8'b01110100;
	assign preCalcTriangle[100] = 8'b01110000;
	assign preCalcTriangle[101] = 8'b01101100;
	assign preCalcTriangle[102] = 8'b01101000;
	assign preCalcTriangle[103] = 8'b01100100;
	assign preCalcTriangle[104] = 8'b01100000;
	assign preCalcTriangle[105] = 8'b01011100;
	assign preCalcTriangle[106] = 8'b01011000;
	assign preCalcTriangle[107] = 8'b01010100;
	assign preCalcTriangle[108] = 8'b01010000;
	assign preCalcTriangle[109] = 8'b01001100;
	assign preCalcTriangle[110] = 8'b01001000;
	assign preCalcTriangle[111] = 8'b01000100;
	assign preCalcTriangle[112] = 8'b01000000;
	assign preCalcTriangle[113] = 8'b00111100;
	assign preCalcTriangle[114] = 8'b00111000;
	assign preCalcTriangle[115] = 8'b00110100;
	assign preCalcTriangle[116] = 8'b00110000;
	assign preCalcTriangle[117] = 8'b00101100;
	assign preCalcTriangle[118] = 8'b00101000;
	assign preCalcTriangle[119] = 8'b00100100;
	assign preCalcTriangle[120] = 8'b00100000;
	assign preCalcTriangle[121] = 8'b00011100;
	assign preCalcTriangle[122] = 8'b00011000;
	assign preCalcTriangle[123] = 8'b00010100;
	assign preCalcTriangle[124] = 8'b00010000;
	assign preCalcTriangle[125] = 8'b00001100;
	assign preCalcTriangle[126] = 8'b00001000;
	assign preCalcTriangle[127] = 8'b00000100;

	//Will count up to 320000.
	reg [15 : 0] counter ; //16 bits max value is 64k ~
	always_ff @(posedge CLK_32KHz, negedge reset_n) begin
		if (reset_n == 1'b0)begin
			counter <= 1'b0;
		end
		else begin
			//If counter reaches top of index, it gets reduced by 32000 but keeps whatever it overshot by.  
			if (counter > 16'd32000 || counter == 16'd32000) begin counter <= counter % 16'd32000; end
			//inputFrequency holds 14 bits, so we need 2 extra in front.
			else begin counter <= counter + inputFrequency;end//{ 2'b0, inputFrequency }; end
		end
	end

	wire [7:0] trueCounter ;
	assign trueCounter = ((counter + (125)) * 1/252 ) ;   // 0.trueCounter == 1/252 
	assign outputSample =preCalcTriangle[trueCounter];  

		
endmodule