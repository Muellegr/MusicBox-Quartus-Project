
//==========================================
//====== ECE 342 JUNIOR DEISGN - W20 - MUSIC BOX
//====== 	Authors : Graham Mueller muellegr@oregonstate.edu
//======


/*
I (Graham) am the main author of this at the moment.  Some things are not commented as well as they should be.
Many things are either out of place (especiall in this file) to make it work with ModelSim or weird debug options that won't be in the final product.

Finally, haven't used branching much before so I'm making weird mistakes trying to use it better.  


MAIN TASKS
	SDRAM Integration
	
	Frequency Generator
	
	Test SPI Output with device
	
	Test SPI Input with device
	
	Integrate LED control to buttons
	
	FFT
		System to pull main frequency out
		
	Add Mode Functionality
		Song 0, Song 1
			Needs frequency generator
			
		Record Song
			Needs FFT
			SDRAM IO
		
		Play Song
			SDRAM IO
			Debug  mode : Fill SDRAM with sine wave to retrieve it properly and output it as if we had recorded something before.



*/
module MusicBox_Main(
	//GPIO
	max10Board_50MhzClock,
	
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
	
	max10Board_GPIO_Input_MusicKeys, //Array
	max10Board_GPIO_Input_PlaySong1,
	max10Board_GPIO_Input_PlaySong0,
	max10Board_GPIO_Input_MakeRecording,
	max10Board_GPIO_Input_PlayRecording,
	
	max10Board_GPIO_Output_SPI_SCLK,
	max10Board_GPIO_Output_SPI_SYNC_n,
	max10Board_GPIO_Output_SPI_DIN,
	
	max10Board_GPIO_Input_SPI_SCLK, //Clock pin.  Technically output!
	max10Board_GPIO_Input_SPI_SDO, //Data pin
	max10Board_GPIO_Input_SPI_CS_n, //Tells ADC to begin sending message.  Technically output!
	//DE10LITE DEDICATED
	max10Board_Buttons,
	max10board_switches,
	max10Board_LEDSegments,
	max10Board_LED

);
	/////////////////////////////////////////////////////////
	/////////////////// MAJOR VARIABLE SETUP ////////////////
	///////// MISC 
	input wire	max10Board_50MhzClock;
	output wire	[5:0][6:0]	max10Board_LEDSegments;//The DE-10 Board LED Segments
	output reg [9:0] max10Board_LED; //The DE-10 Board LED lights
	input wire	[1: 0] max10Board_Buttons ;
	input wire [9:0] max10board_switches;
	///////// GPIO UI ///////
	input wire [5:0] max10Board_GPIO_Input_MusicKeys; //Array
	input wire max10Board_GPIO_Input_PlaySong1;
	input wire max10Board_GPIO_Input_PlaySong0;
	input wire max10Board_GPIO_Input_MakeRecording;
	input wire max10Board_GPIO_Input_PlayRecording;
	///////// GPIO SPI Output to Dac
	output wire max10Board_GPIO_Output_SPI_SCLK; //Data clock per bit
	output wire max10Board_GPIO_Output_SPI_SYNC_n; //Low when sending data
	output wire max10Board_GPIO_Output_SPI_DIN; //Data bits
	///////// GPIO SPI Input from ADC
	output wire max10Board_GPIO_Input_SPI_SCLK; //Clock pin
	input wire max10Board_GPIO_Input_SPI_SDO; //Data pin
	output wire max10Board_GPIO_Input_SPI_CS_n; //Tells ADC to begin sending message
	
	///////// SDRAM /////////
	output wire max10Board_SDRAM_Clock;
	output wire max10Board_SDRAM_ClockEnable;
	output wire [12: 0]   max10Board_SDRAM_Address;
	output wire [ 1: 0]   max10Board_SDRAM_BankAddress;
	inout wire [15: 0]   max10Board_SDRAM_Data;
	 
	
	output wire max10Board_SDRAM_DataMask0;
	output wire max10Board_SDRAM_DataMask1;
	output wire max10Board_SDRAM_ChipSelect_n; //active low
	output wire max10Board_SDRAM_WriteEnable_n; //active low
	output wire max10Board_SDRAM_ColumnAddressStrobe_n; //active low
	output wire max10Board_SDRAM_RowAddressStrobe_n; //active low
	
	/////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////
	//-------------------------
	//-----Major Variables-----
	//-------------------------
	wire systemReset_n = max10Board_Buttons[0]; //Currently all systems should reset on this. 
	//----------------------------
	//-- MAIN MODULE CONTROLLER---
	//----------------------------
	wire [4:0] outputCurrentState; //See MusicBoxStateController for output values
	wire [31:0] output_DebugString; //Typically unused.
	
	/////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////
	//-----------------------
	//--MISC CLOCK GENERATORS
	//-----------------------
	wire CLK_1Khz ;
	ClockGenerator clockGenerator_1Khz (
		.inputClock(max10Board_50MhzClock),
		.reset_n(systemReset_n),
		.outputClock(CLK_1Khz)
	);
		defparam	clockGenerator_1Khz.BitsNeeded = 15; //Must be able to count up to InputClockEdgesToCount.  
		defparam	clockGenerator_1Khz.InputClockEdgesToCount = 25000;
		
	wire CLK_100hz ;
	ClockGenerator clockGenerator_100hz (
		.inputClock(max10Board_50MhzClock),
		.reset_n(systemReset_n),
		.outputClock(CLK_100hz)
	);
		defparam	clockGenerator_100hz.BitsNeeded = 25; //Must be able to count up to InputClockEdgesToCount.  
		defparam	clockGenerator_100hz.InputClockEdgesToCount = 250000;
	
	wire CLK_10hz ;
	ClockGenerator clockGenerator_10hz (
		.inputClock(max10Board_50MhzClock),
		.reset_n(systemReset_n),
		.outputClock(CLK_10hz)
	);
		defparam	clockGenerator_10hz.BitsNeeded = 35; //Must be able to count up to InputClockEdgesToCount.  
		defparam	clockGenerator_10hz.InputClockEdgesToCount = 2500000;
	
	wire CLK_32Khz ;
	ClockGenerator clockGenerator_32Khz (
		.inputClock(max10Board_50MhzClock),
		.reset_n(systemReset_n),
		.outputClock(CLK_32Khz)
	);
		defparam	clockGenerator_32Khz.BitsNeeded = 16; //Must be able to count up to InputClockEdgesToCount.  
		defparam	clockGenerator_32Khz.InputClockEdgesToCount = 781;
	
	wire CLK_1Hz ;
	ClockGenerator clockGenerator_1hz (
		.inputClock(CLK_1Khz),
		.reset_n(systemReset_n),
		.outputClock(CLK_1Hz)
	);
		defparam	clockGenerator_1hz.BitsNeeded = 10; //Must be able to count up to InputClockEdgesToCount.  
		defparam	clockGenerator_1hz.InputClockEdgesToCount = 500;
	
	/////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////
	//----------------------------
	//-- INPUT SMOOTHING----------
	//----------------------------
	//These take the hardware IO and smooth it out over 1ms.
		//These assume active low.
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


	//----------------------------
	//-- Music Keys---------------
	//----------------------------
	//These operate only in the state DoNothing and MakeRecording.  
	wire [5:0] musicKeysDebugTemp ; //Stores output.  Basically input keys if in current state.
	MusicKeysController musicKeysController (
		.clock_50Mhz(max10Board_50MhzClock),
		.reset_n(systemReset_n),
		.currentState(outputCurrentState), //This is controlled by MusicBoxStateController.   
		.input_MusicKey(max10Board_GPIO_Input_MusicKeys_s),
		// .debugString, //This is used to send any data out of the module for testing purposes.  Follows no format.
		.outputKeyPressed(musicKeysDebugTemp)
	);
	


	// assign max10Board_LED[9:4] = musicKeysDebugTemp;
	// assign max10Board_LED[1] = (max10Board_Buttons[1] == 0);
	// assign max10Board_LED[2] = (outputCurrentState == 3);
	// assign max10Board_LED[3] = (outputCurrentState == 4);
	
	/////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////
	//----------------------------
	//-- STATE MACHINE -----------
	//----------------------------
	MusicBoxStateController musicBoxStateController (
		//--INPUT
		.clock_50Mhz(max10Board_50MhzClock),
		.clock_1Khz(CLK_1Khz),
		.reset_n(systemReset_n),
		
		//--USER UI
		.input_PlaySong0_n(max10Board_GPIO_Input_PlaySong0_s),
		.input_PlaySong1_n(max10Board_GPIO_Input_PlaySong1_s),
		.input_MakeRecording_n(max10Board_GPIO_Input_MakeRecording_s),
		.input_PlayRecording_n(max10Board_GPIO_Input_PlayRecording_s),
		.input_MusicKey(max10Board_GPIO_Input_MusicKeys_s),

		//--OUTPUT
		.debugString(output_DebugString), //This is used to send any data out of the module for testing purposes.  Follows no format.
		.outputState(outputCurrentState) //Current state so other modules may use it.
	);
	
	/////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////
	//----------------------------
	//-- SPI Output---------------
	//----------------------------
	//Will always have a set of X bits and a signal to send.
	//The system will take those bits and send them bit by bit in the neccesary way.
	//The system will have a 'IsBusy' flag, and a 'SendComplete' flag.  
	reg [11:0] SPI_Output_WriteSample; //TESTING ONLY
	wire SPI_Output_SendSample_n; //Hardware IO
		assign SPI_Output_SendSample_n = 0;
	wire 		SPI_Output_isBusy; //High when sending a message
	wire 		SPI_Output_transmitComplete;//This goes high briefly when complete
	
	//--TESTING INTERFACE
	// always_ff @ (posedge CLK_100hz, negedge systemReset_n) begin
		// if (systemReset_n == 1'b0) begin
			// SPI_Output_WriteSample <= 1'b0;
		// end
		// else if (SPI_Output_WriteSample == 12'd4095) begin
			// SPI_Output_WriteSample <= 12'd0;
		// end
		// else if ( max10Board_Buttons[1] == 1'b0) begin
			// SPI_Output_WriteSample <= SPI_Output_WriteSample + 12'd1;
		// end
	// end 
	//--This connects with the module that controls the DAC.  The DAC sends signals to the speaker. 
	
	SPI_OutputControllerDac sPI_OutputControllerDac (
		//--INPUT
		.clock_50Mhz(max10Board_50MhzClock),
		.clock_1Khz(CLK_1Khz),
		.reset_n(systemReset_n),
		
		//--CONTROL //* (15'd10 / buttonsActive )
		.inputSample( signalOutputSum  ), //12 bits that will be sent to the DAC
		.sendSample_n(SPI_Output_SendSample_n), //Active low signal.  If the system is not busy, it will begin sending the sample out.
		
		//--OUTPUT
		.output_SPI_SCLK(max10Board_GPIO_Output_SPI_SCLK),
		.output_SPI_SYNC_n(max10Board_GPIO_Output_SPI_SYNC_n),
		.output_SPI_DIN(max10Board_GPIO_Output_SPI_DIN),
		
		//--SIGNAL
		.isBusy(SPI_Output_isBusy),
		.transmitComplete(SPI_Output_transmitComplete) //Goes high for 71Khz when this completes the signal
	);
	
	/////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////
	//----------------------------
	//---SPI Input from ADC ------
	//----------------------------
	wire SPI_ADC_Input_sendSample;
	wire [7:0] SPI_ADC_Output_outputSample;
	wire SPI_ADC_Output_newSample;
	
	SPI_InputControllerDac sPI_InputControllerDac(
		//--INPUT
		.clock_50Mhz(max10Board_50MhzClock),
		.reset_n(systemReset_n),
		
		//--CONTROL
		.sendSample(SPI_ADC_Input_sendSample),

		//--HARDWARE I/O
		.input_SPI_SCLK(max10Board_GPIO_Input_SPI_SCLK),
		.input_SPI_CS_n(max10Board_GPIO_Input_SPI_CS_n),
		.input_SPI_SDO(max10Board_GPIO_Input_SPI_SDO),
		
		//--OUTPUT
		.outputSample(SPI_ADC_Output_outputSample),
		
		//--SIGNAL
		.sampleReady(SPI_ADC_Output_newSample)
	);
	
	/////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////
	//------------------------------------
	//---Frequency Generator Sample ------
	//------------------------------------
	//Generate multiple frequencies at this point.  Tie to music keys.  Add some mild volume control. 


	 
	// SignalGenerator signalGenerator(
	// 	.CLK_32KHz(CLK_32Khz),
	// 	.reset_n(systemReset_n),
	// 	.inputFrequency(({4'b0 , max10board_switches} + {4'b0 , max10board_switches} + {4'b0 , max10board_switches} + {4'b0 , max10board_switches} + + {4'b0 , max10board_switches} + + {4'b0 , max10board_switches}) ),
	// 	.outputSample(signalOutput)
	// );


	wire [15:0] signalOutputSum;
	assign signalOutputSum =   signalOutput[0]*max10board_switches[0]
							 + signalOutput[1]*max10board_switches[1]
							 + signalOutput[2]*max10board_switches[2]
							 + signalOutput[3]*max10board_switches[3]
							 + signalOutput[4]*max10board_switches[4] 
							 + signalOutput[5]*max10board_switches[5] 
							 + signalOutput[6]*max10board_switches[6] 
							 + signalOutput[7]*max10board_switches[7] 
							 + (signalOutput[8]>>1)*max10board_switches[8] 
							 + (signalOutput[9]>>2)*max10board_switches[9];
	reg [9:0][7 : 0] signalOutput;
	wire [15:0] buttonsActive;
	assign buttonsActive = max10board_switches[0] + max10board_switches[1] + max10board_switches[2] + max10board_switches[3] + max10board_switches[4] + max10board_switches[5] + max10board_switches[6] + max10board_switches[7] + max10board_switches[8] + max10board_switches[9];
	//Max value : 10
	
	SignalGenerator signalGenerator0(
		.CLK_32KHz(CLK_32Khz),
		.reset_n(systemReset_n),
		.inputFrequency(14'd100),
		.outputSample(signalOutput[0])
	);
	SignalGenerator signalGenerator1(
		.CLK_32KHz(CLK_32Khz),
		.reset_n(systemReset_n),
		.inputFrequency(14'd101),
		.outputSample(signalOutput[1])
	);
	SignalGenerator signalGenerator2(
		.CLK_32KHz(CLK_32Khz),
		.reset_n(systemReset_n),
		.inputFrequency(14'd103),
		.outputSample(signalOutput[2])
	);
	SignalGenerator signalGenerator3(
		.CLK_32KHz(CLK_32Khz),
		.reset_n(systemReset_n),
		.inputFrequency(14'd160),
		.outputSample(signalOutput[3])
	);
	SignalGenerator signalGenerator4(
		.CLK_32KHz(CLK_32Khz),
		.reset_n(systemReset_n),
		.inputFrequency(14'd200),
		.outputSample(signalOutput[4])
	);
	SignalGenerator signalGenerator5(
		.CLK_32KHz(CLK_32Khz),
		.reset_n(systemReset_n),
		.inputFrequency(14'd202),
		.outputSample(signalOutput[5])
	);
	SignalGenerator signalGenerator6(
		.CLK_32KHz(CLK_32Khz),
		.reset_n(systemReset_n),
		.inputFrequency(14'd206),
		.outputSample(signalOutput[6])
	);
	SignalGenerator signalGenerator7(
		.CLK_32KHz(CLK_32Khz),
		.reset_n(systemReset_n),
		.inputFrequency(14'd350),
		.outputSample(signalOutput[7])
	);
	SignalGenerator signalGenerator8(
		.CLK_32KHz(CLK_32Khz),
		.reset_n(systemReset_n),
		.inputFrequency(14'd450),
		.outputSample(signalOutput[8])
	);
	SignalGenerator signalGenerator9(
		.CLK_32KHz(CLK_32Khz),
		.reset_n(systemReset_n),
		.inputFrequency(14'd600),
		.outputSample(signalOutput[9])
	);


	//Helps show sine wave pattern a bit
	//  assign max10Board_LED[0] = (signalOutput > 005);
	//  assign max10Board_LED[1] = (signalOutput > 032);
	//  assign max10Board_LED[2] = (signalOutput > 059);
	//  assign max10Board_LED[3] = (signalOutput > 086);
	//  assign max10Board_LED[4] = (signalOutput > 113);
	//  assign max10Board_LED[5] = (signalOutput > 140);
	//  assign max10Board_LED[6] = (signalOutput > 167);
	//  assign max10Board_LED[7] = (signalOutput > 194);
	//  assign max10Board_LED[8] = (signalOutput > 221);
	//  assign max10Board_LED[9] = (signalOutput > 250);
	
endmodule