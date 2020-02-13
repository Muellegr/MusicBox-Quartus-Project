/* 
 *	Filename: top_level.sv
 * Author: Tristan Luther
 * Date: 2/4/2020
 * Purpose: Testbench for RGB LED Strip
 */

module top_level(
    input CLK,
    input switch_up,
    input switch_dn,
    output PWM_PIN_R,
	 output PWM_PIN_G,
	 output PWM_PIN_B
    );
	 
wire s_up, s_dn;
reg [25:0] q;

debouncer d1(.CLK (CLK), .switch_in (switch_up), .trans_up (s_up)); // Clean button presses
debouncer d2(.CLK (CLK), .switch_in (switch_dn), .trans_up (s_dn)); // Clean button presses

reg [24:0] color = 24'h000000; //Inital color hexadecimal
reg [1:0] invert = 1;		//Variable for either Common Anode or Common Cathode
reg [6:0] prescaler = 0; // CLK freq / 128 / 256 = 1.5kHz
reg [31:0] counter = 0; // CLK freq used to get 80 BPM

rgb_led l(.pwm_clk (prescaler[0]), .color (color), .invert (invert), .PWM_PIN_R (PWM_PIN_R), .PWM_PIN_G (PWM_PIN_G), .PWM_PIN_B (PWM_PIN_B));

always @(posedge CLK)
begin
  counter <= counter + 1; //Counter for scaling CLK (not currently used)
  prescaler <= prescaler + 1; //Prescaler is used for generating the PWM Frequency
  if(counter == 25000000)
  begin
	color <= 24'h9400D3;
  end
  if(counter == 50000000)
  begin
	color <= 24'h4B0082;
  end
  if(counter == 75000000)
  begin
	color <= 24'h0000FF;
  end
  if(counter == 100000000)
  begin
	color <= 24'h00FF00;
  end
  if(counter == 125000000)
  begin
	color <= 24'hFFFF00;
  end
  if(counter == 150000000)
  begin
	color <= 24'hFF7F00;
  end
  if(counter == 175000000)
  begin
	color <= 24'hFA1010;
	counter <= 0;
  end
end

endmodule
