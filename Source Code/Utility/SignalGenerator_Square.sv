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
		output logic[7 : 0] outputSample,
		output logic indexZero
		);

	reg [15 : 0] counter ; //16 bits max value is 64k ~
	always_ff @(posedge CLK_32KHz, negedge reset_n) begin
		if (reset_n == 1'b0)begin
			counter <= 1'b0;
		end
		else begin
			if (counter >= (16'd32000)) begin counter <= counter - (16'd32000 ) + inputFrequency; end
			else begin counter <= counter + inputFrequency;end//{ 2'b0, inputFrequency }; end
		end
	end

	wire [7:0] trueCounter ;

	assign trueCounter = ( ( counter % 16'd32000) * 1/250 ) ;   // 0.trueCounter == 1/252 
	assign outputSample =squareWave[trueCounter];  
	assign indexZero = (trueCounter == 0) ? 1'b1 : 1'b0;
	//---------------------------------------------------------------------------
	//  [Amount of bits -1] Name [AmountOfSamples]
	bit [7:0] squareWave[127:0];
	//Generated with python in \Python Support\SineValues\GenerateValues_Assign.py
	assign squareWave[0] = 8'b00000000;
	assign squareWave[1] = 8'b00000000;
	assign squareWave[2] = 8'b00000000;
	assign squareWave[3] = 8'b00000000;
	assign squareWave[4] = 8'b00000000;
	assign squareWave[5] = 8'b00000000;
	assign squareWave[6] = 8'b00000000;
	assign squareWave[7] = 8'b00000000;
	assign squareWave[8] = 8'b00000000;
	assign squareWave[9] = 8'b00000000;
	assign squareWave[10] = 8'b00000000;
	assign squareWave[11] = 8'b00000000;
	assign squareWave[12] = 8'b00000000;
	assign squareWave[13] = 8'b00000000;
	assign squareWave[14] = 8'b00000000;
	assign squareWave[15] = 8'b00000000;
	assign squareWave[16] = 8'b00000000;
	assign squareWave[17] = 8'b00000000;
	assign squareWave[18] = 8'b00000000;
	assign squareWave[19] = 8'b00000000;
	assign squareWave[20] = 8'b00000000;
	assign squareWave[21] = 8'b00000000;
	assign squareWave[22] = 8'b00000000;
	assign squareWave[23] = 8'b00000000;
	assign squareWave[24] = 8'b00000000;
	assign squareWave[25] = 8'b00000000;
	assign squareWave[26] = 8'b00000000;
	assign squareWave[27] = 8'b00000000;
	assign squareWave[28] = 8'b00000000;
	assign squareWave[29] = 8'b00000000;
	assign squareWave[30] = 8'b00000000;
	assign squareWave[31] = 8'b00000000;
	assign squareWave[32] = 8'b00000000;
	assign squareWave[33] = 8'b00000000;
	assign squareWave[34] = 8'b00000000;
	assign squareWave[35] = 8'b00000000;
	assign squareWave[36] = 8'b00000000;
	assign squareWave[37] = 8'b00000000;
	assign squareWave[38] = 8'b00000000;
	assign squareWave[39] = 8'b00000000;
	assign squareWave[40] = 8'b00000000;
	assign squareWave[41] = 8'b00000000;
	assign squareWave[42] = 8'b00000000;
	assign squareWave[43] = 8'b00000000;
	assign squareWave[44] = 8'b00000000;
	assign squareWave[45] = 8'b00000000;
	assign squareWave[46] = 8'b00000000;
	assign squareWave[47] = 8'b00000000;
	assign squareWave[48] = 8'b00000000;
	assign squareWave[49] = 8'b00000000;
	assign squareWave[50] = 8'b00000000;
	assign squareWave[51] = 8'b00000000;
	assign squareWave[52] = 8'b00000000;
	assign squareWave[53] = 8'b00000000;
	assign squareWave[54] = 8'b00000000;
	assign squareWave[55] = 8'b00000000;
	assign squareWave[56] = 8'b00000000;
	assign squareWave[57] = 8'b00000000;
	assign squareWave[58] = 8'b00000000;
	assign squareWave[59] = 8'b00000000;
	assign squareWave[60] = 8'b00000000;
	assign squareWave[61] = 8'b00000000;
	assign squareWave[62] = 8'b00000000;
	assign squareWave[63] = 8'b00000000;
	assign squareWave[64] = 8'b11111111;
	assign squareWave[65] = 8'b11111111;
	assign squareWave[66] = 8'b11111111;
	assign squareWave[67] = 8'b11111111;
	assign squareWave[68] = 8'b11111111;
	assign squareWave[69] = 8'b11111111;
	assign squareWave[70] = 8'b11111111;
	assign squareWave[71] = 8'b11111111;
	assign squareWave[72] = 8'b11111111;
	assign squareWave[73] = 8'b11111111;
	assign squareWave[74] = 8'b11111111;
	assign squareWave[75] = 8'b11111111;
	assign squareWave[76] = 8'b11111111;
	assign squareWave[77] = 8'b11111111;
	assign squareWave[78] = 8'b11111111;
	assign squareWave[79] = 8'b11111111;
	assign squareWave[80] = 8'b11111111;
	assign squareWave[81] = 8'b11111111;
	assign squareWave[82] = 8'b11111111;
	assign squareWave[83] = 8'b11111111;
	assign squareWave[84] = 8'b11111111;
	assign squareWave[85] = 8'b11111111;
	assign squareWave[86] = 8'b11111111;
	assign squareWave[87] = 8'b11111111;
	assign squareWave[88] = 8'b11111111;
	assign squareWave[89] = 8'b11111111;
	assign squareWave[90] = 8'b11111111;
	assign squareWave[91] = 8'b11111111;
	assign squareWave[92] = 8'b11111111;
	assign squareWave[93] = 8'b11111111;
	assign squareWave[94] = 8'b11111111;
	assign squareWave[95] = 8'b11111111;
	assign squareWave[96] = 8'b11111111;
	assign squareWave[97] = 8'b11111111;
	assign squareWave[98] = 8'b11111111;
	assign squareWave[99] = 8'b11111111;
	assign squareWave[100] = 8'b11111111;
	assign squareWave[101] = 8'b11111111;
	assign squareWave[102] = 8'b11111111;
	assign squareWave[103] = 8'b11111111;
	assign squareWave[104] = 8'b11111111;
	assign squareWave[105] = 8'b11111111;
	assign squareWave[106] = 8'b11111111;
	assign squareWave[107] = 8'b11111111;
	assign squareWave[108] = 8'b11111111;
	assign squareWave[109] = 8'b11111111;
	assign squareWave[110] = 8'b11111111;
	assign squareWave[111] = 8'b11111111;
	assign squareWave[112] = 8'b11111111;
	assign squareWave[113] = 8'b11111111;
	assign squareWave[114] = 8'b11111111;
	assign squareWave[115] = 8'b11111111;
	assign squareWave[116] = 8'b11111111;
	assign squareWave[117] = 8'b11111111;
	assign squareWave[118] = 8'b11111111;
	assign squareWave[119] = 8'b11111111;
	assign squareWave[120] = 8'b11111111;
	assign squareWave[121] = 8'b11111111;
	assign squareWave[122] = 8'b11111111;
	assign squareWave[123] = 8'b11111111;
	assign squareWave[124] = 8'b11111111;
	assign squareWave[125] = 8'b11111111;
	assign squareWave[126] = 8'b11111111;
	assign squareWave[127] = 8'b11111111;
		
endmodule