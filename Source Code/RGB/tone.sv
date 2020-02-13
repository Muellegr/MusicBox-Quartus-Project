/* 
 *	Filename: tone.sv
 * Author: Tristan Luther
 * Date: 1/18/2020
 * Purpose: Driver for generating tones based on PWM for RGB LEDs
 */
 module tone(
	input CLK, //PWM Clock
	input [31:0] period, //Period for tone duration
	output reg BUZZ_PIN //Output for speaker or buzzer
 );
 
 parameter CLK_F = 50; //CLK Freq in MHz
 
 reg [5:0] prescaler = 0;
 reg [31:0] counter = 0;

always @(posedge CLK)
begin	 
	prescaler <= prescaler + 1;
	if(prescaler == CLK_F/2 - 1)
	begin
		prescaler <= 0;
		counter <= counter + 1;
		if(counter == period - 1)
		begin
			counter <= 0;
			BUZZ_PIN <= ~ BUZZ_PIN;
		end
	end
end

endmodule
