module MusicBox_Main(
	max10Board_Buttons,
	max10board_switches,
	
	max10Board_50MhzClock,
	max10Board_LEDSegments,
	max10Board_LED,
	max10Board_SDRAM_Clock,
	max10Board_SDRAM_ClockEnable,
	max10Board_SDRAM_Address,
	max10Board_SDRAM_BankAddress,
	max10Board_SDRAM_Data,
	max10Board_SDRAM_DataMask0,
	max10Board_SDRAM_DataMask1,
	max10Board_SDRAM_ChipSelect_n,
	max10Board_SDRAM_WriteEnable_n,
	max10Board_SDRAM_ColumnAddressStrobe_n,
	max10Board_SDRAM_RowAddressStrobe_n,
	
	//max10Board_GPIO_Input //
	//max10Board_GPIO_Output //
	
	max10Board_GPIO_Input_MusicKeys, //Array
	max10Board_GPIO_Input_PlaySong1,
	max10Board_GPIO_Input_PlaySong0,
	max10Board_GPIO_Input_MakeRecording,
	max10Board_GPIO_Input_PlayRecording
);
	input wire	max10Board_50MhzClock;
	output wire	[5:0][6:0]	max10Board_LEDSegments;//The DE-10 Board LED Segments
	output reg [9:0] max10Board_LED; //The DE-10 Board LED lights
	
	//input wire [35:11] max10Board_GPIO; 
	//output wire [10:0] max10Board_GPIO; 
	///////// UI GPIO ///////
	input wire [5:0] max10Board_GPIO_Input_MusicKeys; //Array
	input wire max10Board_GPIO_Input_PlaySong1;
	input wire max10Board_GPIO_Input_PlaySong0;
	input wire max10Board_GPIO_Input_MakeRecording;
	input wire max10Board_GPIO_Input_PlayRecording;
	///////// SDRAM /////////
	output wire max10Board_SDRAM_Clock;
	output wire max10Board_SDRAM_ClockEnable;
	output wire [12: 0]   max10Board_SDRAM_Address;
	output wire [ 1: 0]   max10Board_SDRAM_BankAddress;
	inout wire [15: 0]   max10Board_SDRAM_Data;
	input wire [9:0] max10board_switches;
	
	output wire max10Board_SDRAM_DataMask0;
	output wire max10Board_SDRAM_DataMask1;
	output wire max10Board_SDRAM_ChipSelect_n; //active low
	output wire max10Board_SDRAM_WriteEnable_n; //active low
	output wire max10Board_SDRAM_ColumnAddressStrobe_n; //active low
	output wire max10Board_SDRAM_RowAddressStrobe_n; //active low
	/////////////////////////////////////////////////////////
	//-- 
	input wire	[1: 0] max10Board_Buttons ;
	assign max10Board_LED = max10board_switches;
	//assign max10Board_LED[0] = max10board_switches[0];
	//assign max10Board_LED[1] = 1'b1;
	//assign max10Board_LED[9:5] = 1'b0;
	//assign max10Board_LED[4:1] = 1'b1;
	//These are active low switches when used with LVTTL 
	//assign max10Board_LED[9:1] = 1;
	//assign max10Board_LED[0] = max10Board_GPIO_Input_PlaySong0;
	//assign max10Board_LED[1] = !max10Board_GPIO_Input_PlaySong1;
	
	//reg [9:0] incrementCounter;
	//assign max10Board_LED[9:1] = incrementCounter[8:0];
//	assign max10Board_LED[0] = max10Board_GPIO_Input_PlaySong0;
	// always@(posedge max10Board_GPIO_Input_PlaySong0)begin
		// if (max10Board_Buttons[0] == 1) begin
		// //	incrementCounter <= 0;
		// end
		// else begin
		// //	incrementCounter <= incrementCounter + 1;
		// end
	// end
	
	/*
	Do simple button UI
	Do simple button UI on GPIO
		test voltage
		get active low
		active high
		
	*/
	
endmodule