module MusicBox_Main(
	max10Board_Button0,
	max10Board_Button1,
	
	max10board_switches,
	max10Board_LEDs
);


	//-- 
	input wire	max10Board_Button0 ;
	input wire	max10Board_Button1; //Controls reset functionality
	
	input wire [9:0] max10board_switches;
	
	output reg [9:0] max10Board_LEDs; //The LED lights
	
	
endmodule