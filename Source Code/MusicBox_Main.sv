
//==========================================
//====== ECE 342 JUNIOR DEISGN - W20 - MUSIC BOX
//====== 	Authors : Graham Mueller muellegr@oregonstate.edu
//======


/*
MAIN TASKS
	SDRAM Integration
	

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
	input  wire	max10Board_50MhzClock;
	output wire	[5:0][6:0]	max10Board_LEDSegments;//The DE-10 Board LED Segments
	output reg [9:0] max10Board_LED; //The DE-10 Board LED lights
	input  wire	[1: 0] max10Board_Buttons ;
	input  wire [9:0] max10board_switches;
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
	input  wire max10Board_GPIO_Input_SPI_SDO; //Data pin
	output wire max10Board_GPIO_Input_SPI_CS_n; //Tells ADC to begin sending message
	
	///////// SDRAM /////////
	output wire max10Board_SDRAM_Clock;
	output wire max10Board_SDRAM_ClockEnable;
	output wire [12: 0]   max10Board_SDRAM_Address;
	output wire [ 1: 0]   max10Board_SDRAM_BankAddress;
	inout  wire [15: 0]   max10Board_SDRAM_Data;
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
	wire CLK_143Mhz; 
	ALTPLL_Clock aLTPLL_Clock_143Mhz(
		.areset(), //???    Left empty.
		.inclk0(max10Board_50MhzClock), //input clock @ 50Mhz
		.c0(CLK_143Mhz),
		.locked()
	);	
	
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
	//1133
	wire CLK_22Khz ;
	ClockGenerator clockGenerator_22Khz (
		.inputClock(max10Board_50MhzClock),
		.reset_n(systemReset_n),
		.outputClock(CLK_22Khz)
	);
		defparam	clockGenerator_22Khz.BitsNeeded = 16; //Must be able to count up to InputClockEdgesToCount.  
		defparam	clockGenerator_22Khz.InputClockEdgesToCount = 1133;

	wire CLK_32Khz ;
	ClockGenerator clockGenerator_32Khz (
		.inputClock(max10Board_50MhzClock),
		.reset_n(systemReset_n),
		.outputClock(CLK_32Khz)
	);
		defparam	clockGenerator_32Khz.BitsNeeded = 16; //Must be able to count up to InputClockEdgesToCount.  
		defparam	clockGenerator_32Khz.InputClockEdgesToCount = 781;
	
	wire CLK_1hz ;
	ClockGenerator clockGenerator_1hz (
		.inputClock(CLK_1Khz),
		.reset_n(systemReset_n),
		.outputClock(CLK_1hz)
	);
		defparam	clockGenerator_1hz.BitsNeeded = 10; //Must be able to count up to InputClockEdgesToCount.  
		defparam	clockGenerator_1hz.InputClockEdgesToCount = 500;
	
	//-----------------------
	//--7 Segment Display Control. 
	//-----------------------
	reg [19:0] segmentDisplay_DisplayValue ;//= 20'd512;
	 
	SevenSegmentParser sevenSegmentParser(
		.displayValue(segmentDisplay_DisplayValue),
		.segmentPins(max10Board_LEDSegments)
	);
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
			//.inputWire(max10Board_GPIO_Input_PlaySong1),
			.inputWire(max10board_switches[0]),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_PlaySong1_s)
		);
	wire max10Board_GPIO_Input_PlaySong0_s;
		UI_TriggerSmoother UIs_PlaySong0 (
			.clock_50Mhz(max10Board_50MhzClock),
			//.inputWire(max10Board_GPIO_Input_PlaySong0),
			.inputWire(max10board_switches[1]),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_PlaySong0_s)
		);
	wire max10Board_GPIO_Input_MakeRecording_s;
		UI_TriggerSmoother UIs_Makerecording (
			.clock_50Mhz(max10Board_50MhzClock),
			//.inputWire(max10Board_GPIO_Input_MakeRecording),
			.inputWire(max10board_switches[2]),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_MakeRecording_s)
		);
	wire max10Board_GPIO_Input_PlayRecording_s;
		UI_TriggerSmoother UIs_PlayRecording (
			.clock_50Mhz(max10Board_50MhzClock),
			//.inputWire(max10Board_GPIO_Input_PlayRecording),
			.inputWire(max10board_switches[3]),
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
	
	/////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////
	//------------------------------------
	//------- SDRAM Controller -----------
	//------------------------------------
//assign segmentDisplay_DisplayValue =output_DebugString [15:0];

	reg [24:0]	sdram_inputAddress; //This is the address to loop up
	reg [15:0] 	sdram_inputData; //Data to WRITE (only if writing)
	reg [15:0] 	sdram_outputData; //Data from READ (Only if reading)
	reg 		sdram_isWriting; //If 1, we are WRITING.  if 0, we are READING.
	reg			sdram_inputValid; //Tells the SDRAM to perform the action if high. 
	 
	reg			sdram_outputValid; //Tells modules output data is available on the output.
	reg 		sdram_recievedCommand; //Tells modules it recieved the input.
	reg 		sdram_isBusy; //Tells modules if it is working on something (including internal autorefresh)

	SDRAM_Controller sDRAM_Controller (
		//--INTERFACE INPUT.  These control if we read or write.
		.activeClock(CLK_143Mhz), //Configured at 143Mhz 
		.reset_n(systemReset_n),
		
		.address(sdram_inputAddress), //SDRAM copies these two values when it begins a command. These are free to change when 'recievedCommand' goes high.
		.inputData(sdram_inputData),
		
		.isWriting(sdram_isWriting), //If high, SDRAM controller will write.  If low it will read.
		.inputValid(sdram_inputValid), //When it goes high, SDRAM controller will read or write the inputData at the address.
		
		//--INTERFACE OUTPUT.  These give output from read and other signals.
		.outputData(sdram_outputData),
		.outputValid(sdram_outputValid),
		.recievedCommand(sdram_recievedCommand),
		.isBusy(sdram_isBusy),
		//.debugOutputData(segmentDisplay_DisplayValue),
		//--Max10 Hardware IO Pins
		.max10Board_SDRAM_Clock(max10Board_SDRAM_Clock),
		.max10Board_SDRAM_ClockEnable(max10Board_SDRAM_ClockEnable),
		.max10Board_SDRAM_Address(max10Board_SDRAM_Address),
		.max10Board_SDRAM_BankAddress(max10Board_SDRAM_BankAddress),
		.max10Board_SDRAM_Data(max10Board_SDRAM_Data),
		.max10Board_SDRAM_DataMask0(max10Board_SDRAM_DataMask0),
		.max10Board_SDRAM_DataMask1(max10Board_SDRAM_DataMask1),
		.max10Board_SDRAM_ChipSelect_n(max10Board_SDRAM_ChipSelect_n),
		.max10Board_SDRAM_WriteEnable_n(max10Board_SDRAM_WriteEnable_n),
		.max10Board_SDRAM_ColumnAddressStrobe_n(max10Board_SDRAM_ColumnAddressStrobe_n),
		.max10Board_SDRAM_RowAddressStrobe_n(max10Board_SDRAM_RowAddressStrobe_n)
	);

	//----------------------------
	//-- STATE MACHINE -----------
	//----------------------------
	MusicBoxStateController musicBoxStateController (
		//--INPUT
		.clock_50Mhz(max10Board_50MhzClock),
		.clock_22Khz(CLK_22Khz),
		.clock_1Khz(CLK_1Khz),
		.clock_1hz(CLK_1hz),
		.reset_n(systemReset_n),
		//--USER UI
		.input_PlaySong0_n(max10Board_GPIO_Input_PlaySong0_s),
		.input_PlaySong1_n(max10Board_GPIO_Input_PlaySong1_s),
		.input_MakeRecording_n(max10Board_GPIO_Input_MakeRecording_s),
		.input_PlayRecording_n(max10Board_GPIO_Input_PlayRecording_s),
		.input_MusicKey(max10Board_GPIO_Input_MusicKeys_s),
		//--OUTPUT
		.debugString(output_DebugString), //This is used to send any data out of the module for testing purposes.  Follows no format.
		.outputState(outputCurrentState), //Current state so other modules may use it.
		//--SDRAM Interface
		.sdram_inputAddress(sdram_inputAddress),
		.sdram_writeData(sdram_inputData),
		.sdram_readData(sdram_outputData),
		.sdram_isWriting(sdram_isWriting),
		.sdram_inputValid(sdram_inputValid),
		//--
		.sdram_outputValid(sdram_outputValid),
		.sdram_recievedCommand(sdram_recievedCommand),
		.sdram_isBusy(sdram_isBusy)
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
	

	//--This connects with the module that controls the DAC.  The DAC sends signals to the speaker. 
	SPI_OutputControllerDac sPI_OutputControllerDac (
		//--INPUT
		.clock_50Mhz(max10Board_50MhzClock),
		.clock_1Khz(CLK_1Khz),
		.reset_n(systemReset_n),
		//--CONTROL
		.inputSample( {2'b0, signalOutput} * 16'd16 ), //12 bits that will be sent to the DAC
		.sendSample_n(SPI_Output_SendSample_n), //Active low signal.  If the system is not busy, it will begin sending the sample out.
		//--OUTPUT
		.output_SPI_SCLK(max10Board_GPIO_Output_SPI_SCLK),
		.output_SPI_SYNC_n(max10Board_GPIO_Output_SPI_SYNC_n),
		.output_SPI_DIN(max10Board_GPIO_Output_SPI_DIN),
		//--SIGNAL
		.isBusy(SPI_Output_isBusy),
		.transmitComplete(SPI_Output_transmitComplete) //Goes high for 71Khz when this completes the signal
	);
	//
	//
	//
	/////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////
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
	reg [7 : 0] signalOutput;
	SignalGenerator signalGenerator(
		.CLK_32KHz(CLK_32Khz),
		.reset_n(systemReset_n),
		.inputFrequency(({4'b0 , max10board_switches} + {4'b0 , max10board_switches} + {4'b0 , max10board_switches} + {4'b0 , max10board_switches} + + {4'b0 , max10board_switches} + + {4'b0 , max10board_switches}) ),
		.outputSample(signalOutput)
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
	 
	 
	/////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////
	


	//--------SDRAM TESTING INTERFACE
// 	reg isLoading ;
// 	reg [24:0] sdram_testAddressCounter;
// 	reg [10:0][24:0] sdram_TestAddress;
// 	reg [10:0][15:0] sdram_TestInputData;
// 	reg [10:0][15:0] sdram_TestOutputData;
// //	wire [15:0] sdram_inputData;
	
	
//	reg [15:0] sdram_inputDataLoading;
	//	reg [24:0] sdram_inputAddressLoading;

//	reg [15:0] sdram_inputDataTester;
	//reg [24:0] sdram_inpuAddressTester;
	
	//wire sdram_isWriting ;
	//	reg	sdram_isWritingLoading;
	//reg sdram_isWritingTester;
	

	//wire sdram_inputValid ;
	//	reg sdram_inputValidLoading;
	//reg sdram_inputValidTester;

	//assign sdram_inputAddress = sdram_inpuAddressTester;
	//assign sdram_isWriting = sdram_isWritingTester;
	//assign sdram_inputValid =  sdram_inputValidTester;
	//assign sdram_inputData = sdram_inputDataTester;//sdram_inputDataLoading;

	//wire [4:0] index;
	
	reg sdRamTest_CompareError ;
	reg sdRamTest_CompletedSuccess ;
	assign max10Board_LED[0] = 1;
	assign max10Board_LED[1] = sdRamTest_CompareError;
	assign max10Board_LED[2] = sdRamTest_CompletedSuccess;
	assign max10Board_LED[3] = sdram_isBusy;
	assign max10Board_LED[4] = sdram_inputValid;
	assign max10Board_LED[5] = sdram_isWriting;
	assign max10Board_LED[6] = sdram_recievedCommand;
	assign max10Board_LED[7] = sdram_outputValid;

	 
	
	//outputData (sdram_inputDataTester) is used for WRITING. 
	
	
	// // //--A test module that incrmeents through all of this.
	// SDRAM_TestModule sdRamTest (
	// 	.inputClock(CLK_143Mhz), //Clock  CLK_143Mhz
	// 	.reset_n(systemReset_n), //Reset, active low
	// 	.isBusy(sdram_isBusy), //Is the SDRAm saying it's busy
	// 	.recievedCommand(sdram_recievedCommand),
		
	// 	.isWriting(sdram_isWritingTester), //If we say output is valid, is it writing
	// 	.outputValid(sdram_inputValidTester), //Should we try a new command
	// 	.outputAddress(sdram_inpuAddressTester), //Address this writes data to
	// 	.outputData(sdram_inputDataTester), //Data to write
	// 	.inputDataAvailable(sdram_outputValid), //High when data from reading is available
	// 	.inputData(sdram_outputData), // Data from reading
	// 	.compareError(sdRamTest_CompareError), //If we arrived at an error
	// 	.completedSuccess(sdRamTest_CompletedSuccess) //If we were successful
	// 	//.outputValue( segmentDisplay_DisplayValue) //Current increment, updated every 0.25 seconds
	// );


endmodule