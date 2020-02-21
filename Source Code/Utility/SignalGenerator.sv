/*
Signal Generator - Creates a sine wave that has the supplied input frequency.
	Operates from 100Hz to 8000Hz.  
	
	outputSample is the current sine amplitude.
	
	
	This is a bit hardcoded to 128 total samples at a 32000 clock but can be changed by modifying some of the constants.
*/

module SignalGenerator  ( 
		input logic CLK_32KHz,
		input logic reset_n,
		input logic[13:0] inputFrequency,
		output logic[7 : 0] outputSample,
		output logic indexZero
		);
		

	//Will count up to 320000.
	reg [15 : 0] counter ; //16 bits max value is 64k ~
	always_ff @(posedge CLK_32KHz, negedge reset_n) begin
		if (reset_n == 1'b0)begin
			counter <= 1'b0;
		end
		else begin
			//If counter reaches top of index, it gets reduced by 32000 but keeps whatever it overshot by.  
			if (counter >= (16'd32000)) begin counter <= counter - (16'd32000 ) + inputFrequency; end
			//inputFrequency holds 14 bits, so we need 2 extra in front.
			else begin counter <= counter + inputFrequency;end//{ 2'b0, inputFrequency }; end
		end
	end

	wire [7:0] trueCounter ;

	assign trueCounter = ( ( counter % 16'd32000) * 1/250 ) ;   // 0.trueCounter == 1/252 
	assign outputSample =preCalcSine[trueCounter];  
	assign indexZero = (trueCounter == 0) ? 1'b1 : 1'b0;


	//--------------------------------------------
	//  [Amount of bits -1] Name [AmountOfSamples]
	bit [7:0] preCalcSine[127:0];
	//Generated with python in \Python Support\SineValues\GenerateValues_Assign.py
	assign preCalcSine[0] = 8'b00000000;
	assign preCalcSine[1] = 8'b00000000;
	assign preCalcSine[2] = 8'b00000001;
	assign preCalcSine[3] = 8'b00000001;
	assign preCalcSine[4] = 8'b00000010;
	assign preCalcSine[5] = 8'b00000100;
	assign preCalcSine[6] = 8'b00000110;
	assign preCalcSine[7] = 8'b00000111;
	assign preCalcSine[8] = 8'b00001010;
	assign preCalcSine[9] = 8'b00001100;
	assign preCalcSine[10] = 8'b00001111;
	assign preCalcSine[11] = 8'b00010010;
	assign preCalcSine[12] = 8'b00010110;
	assign preCalcSine[13] = 8'b00011001;
	assign preCalcSine[14] = 8'b00011101;
	assign preCalcSine[15] = 8'b00100001;
	assign preCalcSine[16] = 8'b00100101;
	assign preCalcSine[17] = 8'b00101010;
	assign preCalcSine[18] = 8'b00101111;
	assign preCalcSine[19] = 8'b00110100;
	assign preCalcSine[20] = 8'b00111001;
	assign preCalcSine[21] = 8'b00111110;
	assign preCalcSine[22] = 8'b01000100;
	assign preCalcSine[23] = 8'b01001001;
	assign preCalcSine[24] = 8'b01001111;
	assign preCalcSine[25] = 8'b01010101;
	assign preCalcSine[26] = 8'b01011011;
	assign preCalcSine[27] = 8'b01100001;
	assign preCalcSine[28] = 8'b01100111;
	assign preCalcSine[29] = 8'b01101101;
	assign preCalcSine[30] = 8'b01110011;
	assign preCalcSine[31] = 8'b01111010;
	assign preCalcSine[32] = 8'b10000000;
	assign preCalcSine[33] = 8'b10000110;
	assign preCalcSine[34] = 8'b10001101;
	assign preCalcSine[35] = 8'b10010011;
	assign preCalcSine[36] = 8'b10011001;
	assign preCalcSine[37] = 8'b10011111;
	assign preCalcSine[38] = 8'b10100101;
	assign preCalcSine[39] = 8'b10101011;
	assign preCalcSine[40] = 8'b10110001;
	assign preCalcSine[41] = 8'b10110111;
	assign preCalcSine[42] = 8'b10111100;
	assign preCalcSine[43] = 8'b11000010;
	assign preCalcSine[44] = 8'b11000111;
	assign preCalcSine[45] = 8'b11001100;
	assign preCalcSine[46] = 8'b11010001;
	assign preCalcSine[47] = 8'b11010110;
	assign preCalcSine[48] = 8'b11011011;
	assign preCalcSine[49] = 8'b11011111;
	assign preCalcSine[50] = 8'b11100011;
	assign preCalcSine[51] = 8'b11100111;
	assign preCalcSine[52] = 8'b11101010;
	assign preCalcSine[53] = 8'b11101110;
	assign preCalcSine[54] = 8'b11110001;
	assign preCalcSine[55] = 8'b11110100;
	assign preCalcSine[56] = 8'b11110110;
	assign preCalcSine[57] = 8'b11111001;
	assign preCalcSine[58] = 8'b11111010;
	assign preCalcSine[59] = 8'b11111100;
	assign preCalcSine[60] = 8'b11111110;
	assign preCalcSine[61] = 8'b11111111;
	assign preCalcSine[62] = 8'b11111111;
	assign preCalcSine[63] = 8'b11111111;
	assign preCalcSine[64] = 8'b11111111;
	assign preCalcSine[65] = 8'b11111111;
	assign preCalcSine[66] = 8'b11111111;
	assign preCalcSine[67] = 8'b11111111;
	assign preCalcSine[68] = 8'b11111110;
	assign preCalcSine[69] = 8'b11111100;
	assign preCalcSine[70] = 8'b11111010;
	assign preCalcSine[71] = 8'b11111001;
	assign preCalcSine[72] = 8'b11110110;
	assign preCalcSine[73] = 8'b11110100;
	assign preCalcSine[74] = 8'b11110001;
	assign preCalcSine[75] = 8'b11101110;
	assign preCalcSine[76] = 8'b11101010;
	assign preCalcSine[77] = 8'b11100111;
	assign preCalcSine[78] = 8'b11100011;
	assign preCalcSine[79] = 8'b11011111;
	assign preCalcSine[80] = 8'b11011011;
	assign preCalcSine[81] = 8'b11010110;
	assign preCalcSine[82] = 8'b11010001;
	assign preCalcSine[83] = 8'b11001100;
	assign preCalcSine[84] = 8'b11000111;
	assign preCalcSine[85] = 8'b11000010;
	assign preCalcSine[86] = 8'b10111100;
	assign preCalcSine[87] = 8'b10110111;
	assign preCalcSine[88] = 8'b10110001;
	assign preCalcSine[89] = 8'b10101011;
	assign preCalcSine[90] = 8'b10100101;
	assign preCalcSine[91] = 8'b10011111;
	assign preCalcSine[92] = 8'b10011001;
	assign preCalcSine[93] = 8'b10010011;
	assign preCalcSine[94] = 8'b10001101;
	assign preCalcSine[95] = 8'b10000110;
	assign preCalcSine[96] = 8'b10000000;
	assign preCalcSine[97] = 8'b01111010;
	assign preCalcSine[98] = 8'b01110011;
	assign preCalcSine[99] = 8'b01101101;
	assign preCalcSine[100] = 8'b01100111;
	assign preCalcSine[101] = 8'b01100001;
	assign preCalcSine[102] = 8'b01011011;
	assign preCalcSine[103] = 8'b01010101;
	assign preCalcSine[104] = 8'b01001111;
	assign preCalcSine[105] = 8'b01001001;
	assign preCalcSine[106] = 8'b01000100;
	assign preCalcSine[107] = 8'b00111110;
	assign preCalcSine[108] = 8'b00111001;
	assign preCalcSine[109] = 8'b00110100;
	assign preCalcSine[110] = 8'b00101111;
	assign preCalcSine[111] = 8'b00101010;
	assign preCalcSine[112] = 8'b00100101;
	assign preCalcSine[113] = 8'b00100001;
	assign preCalcSine[114] = 8'b00011101;
	assign preCalcSine[115] = 8'b00011001;
	assign preCalcSine[116] = 8'b00010110;
	assign preCalcSine[117] = 8'b00010010;
	assign preCalcSine[118] = 8'b00001111;
	assign preCalcSine[119] = 8'b00001100;
	assign preCalcSine[120] = 8'b00001010;
	assign preCalcSine[121] = 8'b00000111;
	assign preCalcSine[122] = 8'b00000110;
	assign preCalcSine[123] = 8'b00000100;
	assign preCalcSine[124] = 8'b00000010;
	assign preCalcSine[125] = 8'b00000001;
	assign preCalcSine[126] = 8'b00000001;
	assign preCalcSine[127] = 8'b00000000;

endmodule