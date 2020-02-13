/* 
 *	Filename: rgb_led.sv
 * Author: Tristan Luther
 * Date: 1/17/2020
 * Purpose: Driver for RGB LEDs
 */
module rgb_led(
    input pwm_clk,
	 input [24:0] color,
	 input [1:0] invert,
    output reg PWM_PIN_R,
	 output reg PWM_PIN_G,
	 output reg PWM_PIN_B
    );

	reg [7:0] count = 0;
	reg [7:0] duty_red = 0;
	reg [7:0] duty_green = 0;
	reg [7:0] duty_blue = 0;

	assign duty_red[7:0] = color[24:17];
	assign duty_green[7:0] = color[16:8];
	assign duty_blue[7:0] = color[7:0];

	always @(posedge pwm_clk)
		begin
			//If the hex color should not be inverted
			if(!invert)
				begin
					  count <= count + 1;
					  PWM_PIN_R <= (count < duty_red);
					  PWM_PIN_G <= (count < duty_green);
					  PWM_PIN_B <= (count < duty_blue);
				end
			//If the hex color should be inverted
			else
				begin
					  count <= count + 1;
					  PWM_PIN_R <= (count < ~duty_red);
					  PWM_PIN_G <= (count < ~duty_green);
					  PWM_PIN_B <= (count < ~duty_blue);
				end
		end

endmodule
