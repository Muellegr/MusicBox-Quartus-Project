

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
	//assign max10Board_LED = max10board_switches;
	//assign max10Board_LED[0] = max10board_switches[0];
	//assign max10Board_LED[1] = 1'b1;
	//assign max10Board_LED[9:5] = 1'b0;
	//assign max10Board_LED[4:1] = 1'b1;
	//These are active low switches when used with LVTTL 
	//assign max10Board_LED[9:1] = 1;
	//assign max10Board_LED[0] = max10Board_GPIO_Input_PlaySong0;
	//assign max10Board_LED[1] = !max10Board_GPIO_Input_PlaySong1;
	
	reg [9:0] incrementCounter;
	 
	
	//assign max10Board_LED[7:0] = incrementCounter;
	//assign max10Board_LED[9] = max10Board_GPIO_Input_PlaySong0_s;
	//assign max10Board_LED[8] = max10Board_GPIO_Input_PlaySong0;
	
	//-------------------------
	//-----Major Variables-----
	//-------------------------
	wire systemReset_n = max10Board_Buttons[0];
	
	
	
	always@(negedge max10Board_GPIO_Input_PlaySong0_s) begin
		if (systemReset_n == 1'b0) begin
			incrementCounter = 0;
		end
		else begin
			incrementCounter = incrementCounter + 1;
		end
	end
	
	//----------------------------
	//-- MAIN MODULE CONTROLLER---
	//----------------------------
	wire [4:0] outputCurrentState;
	
	assign max10Board_LED[9] = CLK_1Hz;
	assign max10Board_LED[8] = CLK_1kHz;
	
	//assign max10Board_LED[9:5] = musicKeysDebugTemp;
	assign max10Board_LED[4:0] = outputCurrentState;
	MusicBoxStateController musicBoxStateController (
		//==INPUT
		.clock_50Mhz(max10Board_50MhzClock),
		.reset_n(systemReset_n),
		//--UI
		.input_PlaySong0_n(max10Board_GPIO_Input_PlaySong0_s),
		.input_PlaySong1_n(max10Board_GPIO_Input_PlaySong1_s),
		.input_MakeRecording_n(max10Board_GPIO_Input_MakeRecording_s),
		.input_PlayRecording_n(max10Board_GPIO_Input_PlayRecording_s),
		.input_MusicKey(max10Board_GPIO_Input_MusicKeys_s),
		
		
		//==OUTPUT
		//.debugString, //This is used to send any data out of the module for testing purposes.  Follows no format.
		.outputState(outputCurrentState) //
	
	);
	//----------------------------
	//-- Music Keys
	wire [5:0] musicKeysDebugTemp ; //Stores output.  Basically input keys if in current state.
	MusicKeysController musicKeysController (
		.clock_50Mhz(max10Board_50MhzClock),
		.reset_n(systemReset_n),
		.currentState(outputCurrentState), //This is controlled by MusicBoxStateController.   
		.input_MusicKey(max10Board_GPIO_Input_MusicKeys_s),
		// .debugString, //This is used to send any data out of the module for testing purposes.  Follows no format.
		.outputKeyPressed(musicKeysDebugTemp)

	);
	
	
	
	//----------------------------
	//-- INPUT SMOOTHING----------
	//----------------------------
	wire [5:0] max10Board_GPIO_Input_MusicKeys_s; //Array
		UI_TriggerSmoother UIs_MusicKeys0 (
			.clock_50Mhz(max10Board_50MhzClock),
			.inputWire(max10Board_GPIO_Input_MusicKeys[0]),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_MusicKeys_s[0])
		);
		UI_TriggerSmoother UIs_MusicKeys1 (
			.clock_50Mhz(max10Board_50MhzClock),
			.inputWire(max10Board_GPIO_Input_MusicKeys[1]),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_MusicKeys_s[1])
		);
		UI_TriggerSmoother UIs_MusicKeys2 (
			.clock_50Mhz(max10Board_50MhzClock),
			.inputWire(max10Board_GPIO_Input_MusicKeys[2]),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_MusicKeys_s[2])
		);
		UI_TriggerSmoother UIs_MusicKeys3 (
			.clock_50Mhz(max10Board_50MhzClock),
			.inputWire(max10Board_GPIO_Input_MusicKeys[3]),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_MusicKeys_s[3])
		);
		UI_TriggerSmoother UIs_MusicKeys4 (
			.clock_50Mhz(max10Board_50MhzClock),
			.inputWire(max10Board_GPIO_Input_MusicKeys[4]),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_MusicKeys_s[4])
		);
		UI_TriggerSmoother UIs_MusicKeys5 (
			.clock_50Mhz(max10Board_50MhzClock),
			.inputWire(max10Board_GPIO_Input_MusicKeys[5]),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_MusicKeys_s[5])
		);
	wire max10Board_GPIO_Input_PlaySong1_s;
		UI_TriggerSmoother UIs_PlaySong1 (
			.clock_50Mhz(max10Board_50MhzClock),
			.inputWire(max10Board_GPIO_Input_PlaySong1),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_PlaySong1_s)
		);
	wire max10Board_GPIO_Input_PlaySong0_s;
		UI_TriggerSmoother UIs_PlaySong0 (
			.clock_50Mhz(max10Board_50MhzClock),
			.inputWire(max10Board_GPIO_Input_PlaySong0),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_PlaySong0_s)
		);
	wire max10Board_GPIO_Input_MakeRecording_s;
		UI_TriggerSmoother UIs_Makerecording (
			.clock_50Mhz(max10Board_50MhzClock),
			.inputWire(max10Board_GPIO_Input_MakeRecording),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_MakeRecording_s)
		);
	wire max10Board_GPIO_Input_PlayRecording_s;
		UI_TriggerSmoother UIs_PlayRecording (
			.clock_50Mhz(max10Board_50MhzClock),
			.inputWire(max10Board_GPIO_Input_PlayRecording),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_PlayRecording_s)
		);
	
	//--MISC CLOCK GENERATORS
	wire CLK_1kHz ;
	ClockGenerator clockGenerator_1Khz (
		.inputClock(max10Board_50MhzClock),
		.reset_n(systemReset_n),
		.outputClock(CLK_1kHz)
	);
	defparam	clockGenerator_1Khz.BitsNeeded = 15; //Must be able to count up to InputClockEdgesToCount.  
	defparam	clockGenerator_1Khz.InputClockEdgesToCount = 25000;
	
	wire CLK_1Hz ;
	ClockGenerator clockGenerator_1hz (
		.inputClock(CLK_1kHz),
		.reset_n(systemReset_n),
		.outputClock(CLK_1Hz)
	);
	defparam	clockGenerator_1hz.BitsNeeded = 10; //Must be able to count up to InputClockEdgesToCount.  
	defparam	clockGenerator_1hz.InputClockEdgesToCount = 500;
	
endmodule