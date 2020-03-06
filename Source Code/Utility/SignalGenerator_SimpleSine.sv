/*
Signal Generator - Creates a sine wave that has the supplied input frequency.
	Operates from 100Hz to 8000Hz.  
	
	outputSample is the current sine amplitude.
	
	
	This is a bit hardcoded to 128 total samples at a 32000 clock but can be changed by modifying some of the constants.
*/

module SignalGenerator_SimpleSine  ( 
		input logic CLK_32KHz,
		input logic reset_n,
		input logic[13:0] inputFrequency,
		input logic [7:0] inputAmplitude, //Can give it a constant amplitude as well
		input logic [7:0] inputOffset, //Offset starting value
		output logic[7 : 0] outputSample,
		output logic indexZero
		);
		

	//Will count up to 320000.
	reg [15 : 0] counter ; //16 bits max value is 64k ~
	always_ff @(posedge CLK_32KHz, negedge reset_n) begin
		if (reset_n == 1'b0)begin
			counter <= inputOffset * 125;
		end
		else begin
			//If counter reaches top of index, it gets reduced by 32000 but keeps whatever it overshot by.  
			if (counter >= (16'd32000)) begin counter <= counter - (16'd32000 ) + inputFrequency; end
			//inputFrequency holds 14 bits, so we need 2 extra in front.
			else begin counter <= counter + inputFrequency;end//{ 2'b0, inputFrequency }; end
		end
	end

	wire [7:0] trueCounter ;

	assign trueCounter = ( ( counter % 16'd32000) * 1/500 ) ;   // 0.trueCounter == 1/252 
	assign outputSample = preCalcSine[trueCounter];//SignalMultiply255(preCalcSine[trueCounter],inputAmplitude );   //Combine amplitude with input.  
	assign indexZero = (trueCounter == 0) ? 1'b1 : 1'b0;

	//Combines tow signals into 1
	

	//--------------------------------------------
	//  [Amount of bits -1] Name [AmountOfSamples]
	bit [7:0] preCalcSine[127:0];
	//Generated with python in \Python Support\SineValues\GenerateValues_Assign.py
	assign preCalcSine[0] = 8'b00000000;
assign preCalcSine[1] = 8'b00000000;
assign preCalcSine[2] = 8'b00000000;
assign preCalcSine[3] = 8'b00000000;
assign preCalcSine[4] = 8'b00000000;
assign preCalcSine[5] = 8'b00000000;
assign preCalcSine[6] = 8'b00000000;
assign preCalcSine[7] = 8'b00000000;
assign preCalcSine[8] = 8'b00000000;
assign preCalcSine[9] = 8'b00000000;
assign preCalcSine[10] = 8'b00000000;
assign preCalcSine[11] = 8'b00000000;
assign preCalcSine[12] = 8'b00000000;
assign preCalcSine[13] = 8'b00000000;
assign preCalcSine[14] = 8'b00000000;
assign preCalcSine[15] = 8'b00000000;
assign preCalcSine[16] = 8'b00000000;
assign preCalcSine[17] = 8'b00000000;
assign preCalcSine[18] = 8'b00000000;
assign preCalcSine[19] = 8'b00000000;
assign preCalcSine[20] = 8'b00000000;
assign preCalcSine[21] = 8'b00000000;
assign preCalcSine[22] = 8'b00000000;
assign preCalcSine[23] = 8'b00000000;
assign preCalcSine[24] = 8'b00000000;
assign preCalcSine[25] = 8'b00000000;
assign preCalcSine[26] = 8'b00000000;
assign preCalcSine[27] = 8'b00000000;
assign preCalcSine[28] = 8'b00000000;
assign preCalcSine[29] = 8'b00000000;
assign preCalcSine[30] = 8'b00000000;
assign preCalcSine[31] = 8'b00000000;
assign preCalcSine[32] = 8'b00000000;
assign preCalcSine[33] = 8'b00000000;
assign preCalcSine[34] = 8'b00000000;
assign preCalcSine[35] = 8'b00000000;
assign preCalcSine[36] = 8'b00000000;
assign preCalcSine[37] = 8'b00000000;
assign preCalcSine[38] = 8'b00000000;
assign preCalcSine[39] = 8'b00000000;
assign preCalcSine[40] = 8'b00000000;
assign preCalcSine[41] = 8'b00000000;
assign preCalcSine[42] = 8'b00000000;
assign preCalcSine[43] = 8'b00000000;
assign preCalcSine[44] = 8'b00000000;
assign preCalcSine[45] = 8'b00000000;
assign preCalcSine[46] = 8'b00000000;
assign preCalcSine[47] = 8'b00000000;
assign preCalcSine[48] = 8'b00000000;
assign preCalcSine[49] = 8'b00000000;
assign preCalcSine[50] = 8'b00000000;
assign preCalcSine[51] = 8'b00000000;
assign preCalcSine[52] = 8'b00000000;
assign preCalcSine[53] = 8'b00000000;
assign preCalcSine[54] = 8'b00000000;
assign preCalcSine[55] = 8'b00000000;
assign preCalcSine[56] = 8'b00000000;
assign preCalcSine[57] = 8'b00000000;
assign preCalcSine[58] = 8'b00000000;
assign preCalcSine[59] = 8'b00000000;
assign preCalcSine[60] = 8'b00000000;
assign preCalcSine[61] = 8'b00000000;
assign preCalcSine[62] = 8'b00000000;
assign preCalcSine[63] = 8'b00000000;

endmodule