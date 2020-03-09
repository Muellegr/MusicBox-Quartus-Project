
//==========================================
//====== ECE 342 JUNIOR DEISGN - W20 - MUSIC BOX
//====== 	Authors : Graham Mueller muellegr@oregonstate.edu
//======			  Tristan Luther luthert@oregonstate.edu 
//======



/*
TODO TEST
	ROM
		Test if it is working correctly
		Test if addressing is working correctly
		Feed it a long sine wave as a test - check how it looks on display (should appear correct, hit peaks)
			sine wave + square for max amplitude test

		Add song 0, song 1, bee noise

	Bee noise implementation
		
	Add early song stop

	Add bee mode indicator lighting
		rapid pulse if on?


SYSTEM INTEGRATION BRANCH
	-Currently will be configured to use DE10 lite switches.
		-Switch 0 is play song 0, 
		-S1 for S1
		-S2 for make recording
		-S3 for Play recording
		-S4-8 for Music Keys
		-S9 for Bee Mode

TODO

	Integrate ROM module
		Create working module 

	BIG THINGS
		LED integratoin
		ADC input connections
		DAC output connections
		Music Keys
		Song 0, Song 1
	
EXTRA GOALS
	Signal generator : Amplitude delayed to prevent instant time changes (small averaging value that is clamped.  Works off clock signal!)
	Secret Songs : Combinational check for songs

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
	max10Board_GPIO_Output_MusicKeys_LEDs,
	max10Board_GPIO_Input_PlaySong1,
	max10Board_GPIO_Input_PlaySong0,
	max10Board_GPIO_Input_MakeRecording,
	max10Board_GPIO_Input_PlayRecording,
	max10Board_GPIO_Input_BeeMode,
	max10Board_GPIO_Output_ModeKeys_LEDs,
	max10Board_GPIO_Output_SideLEDs,
	
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
	output wire [5:0][2:0] max10Board_GPIO_Output_MusicKeys_LEDs; //Each music key has 3 RGB LEDs assigned in that order.  
	output wire [4:0] max10Board_GPIO_Output_ModeKeys_LEDs; //Each mode key has only 1 LED assigned to it.  [SONG0, SONG1, MAKE RECORDING, PLAY RECORDING, BEE ]  
	output wire [2:0] max10Board_GPIO_Output_SideLEDs; //Each mode key has only 1 LED assigned to it.  [SONG0, SONG1, MAKE RECORDING, PLAY RECORDING, BEE ]  
	input wire max10Board_GPIO_Input_PlaySong1;
	input wire max10Board_GPIO_Input_PlaySong0;
	input wire max10Board_GPIO_Input_MakeRecording;
	input wire max10Board_GPIO_Input_PlayRecording;
	input wire max10Board_GPIO_Input_BeeMode;
	///////// GPIO SPI Output to Dac
	output wire max10Board_GPIO_Output_SPI_SCLK; //Data clock per bit
	output wire max10Board_GPIO_Output_SPI_SYNC_n; //Low when sending data
	output wire max10Board_GPIO_Output_SPI_DIN; //Data bits
	///////// GPIO SPI Input from ADC
	input wire max10Board_GPIO_Input_SPI_SCLK; //Clock pin
	input wire max10Board_GPIO_Input_SPI_SDO; //Data pin
	input wire max10Board_GPIO_Input_SPI_CS_n; //Tells ADC to begin sending message
	
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
	//ISSUE : Clocks should be 97.5% slower.  I think the 50Mhz clock is not exactly 50Mhz.  
	wire CLK_143Mhz; 
	ALTPLL_Clock aLTPLL_Clock_143Mhz(
		.areset(), //???    Left empty.
		.inclk0(max10Board_50MhzClock), //input clock @ 50Mhz
		.c0(CLK_143Mhz),
		.locked()
	);	

	wire CLK_32Khz ;
	ClockGenerator clockGenerator_32Khz (
		.inputClock(max10Board_50MhzClock),
		.reset_n(systemReset_n),
		.outputClock(CLK_32Khz)
	);
		defparam	clockGenerator_32Khz.BitsNeeded = 16; //Must be able to count up to InputClockEdgesToCount.  
		defparam	clockGenerator_32Khz.InputClockEdgesToCount = 781; //OLD : 781* 0.975 = 762

	wire CLK_22Khz ;
	ClockGenerator clockGenerator_22Khz (
		.inputClock(max10Board_50MhzClock),
		.reset_n(systemReset_n),
		.outputClock(CLK_22Khz)
	);
		defparam	clockGenerator_22Khz.BitsNeeded = 16; //Must be able to count up to InputClockEdgesToCount.  
		defparam	clockGenerator_22Khz.InputClockEdgesToCount = 1133;

	
	wire CLK_10Khz ;
	ClockGenerator clockGenerator_10Khz (
		.inputClock(max10Board_50MhzClock),
		.reset_n(systemReset_n),
		.outputClock(CLK_10Khz)
	);
		defparam	clockGenerator_10Khz.BitsNeeded = 16; //Must be able to count up to InputClockEdgesToCount.  
		defparam	clockGenerator_10Khz.InputClockEdgesToCount = 2500; //OLD : 781* 0.975 = 762

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

	wire CLK_500Khz ;
	ClockGenerator clockGenerator_500Khz (
		.inputClock(max10Board_50MhzClock),
		.reset_n(systemReset_n),
		.outputClock(CLK_500Khz)
	);
		defparam	clockGenerator_500Khz.BitsNeeded = 16; //Must be able to count up to InputClockEdgesToCount.  
		defparam	clockGenerator_500Khz.InputClockEdgesToCount = 50; //OLD : 781* 0.975 = 762
	
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
	reg [19:0] segmentDisplay_DisplayValue ;
	 
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
	assign max10Board_LED[0] = max10board_switches[4] && max10Board_GPIO_Input_MusicKeys[0];
	wire [5:0] max10Board_GPIO_Input_MusicKeys_s; //Array
		UI_TriggerSmoother UIs_MusicKeys0 (
			.clock_50Mhz(CLK_1Khz),
			//.inputWire(max10Board_GPIO_Input_MusicKeys[0]),
			.inputWire(max10board_switches[4] && max10Board_GPIO_Input_MusicKeys[0] ),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_MusicKeys_s[0])
		);
		UI_TriggerSmoother UIs_MusicKeys1 (
			.clock_50Mhz(CLK_1Khz),
			//.inputWire(max10Board_GPIO_Input_MusicKeys[1]),
			.inputWire(max10board_switches[5] && max10Board_GPIO_Input_MusicKeys[1]),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_MusicKeys_s[1])
		);
		UI_TriggerSmoother UIs_MusicKeys2 (
			.clock_50Mhz(CLK_1Khz),
			//.inputWire(max10Board_GPIO_Input_MusicKeys[2]),
			.inputWire(max10board_switches[6] && max10Board_GPIO_Input_MusicKeys[2]),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_MusicKeys_s[2])
		);
		UI_TriggerSmoother UIs_MusicKeys3 (
			.clock_50Mhz(CLK_1Khz),
			//.inputWire(max10Board_GPIO_Input_MusicKeys[3]),
			.inputWire(max10board_switches[7] && max10Board_GPIO_Input_MusicKeys[3]),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_MusicKeys_s[3])
		);
		UI_TriggerSmoother UIs_MusicKeys4 (
			.clock_50Mhz(CLK_1Khz),
			//.inputWire(max10Board_GPIO_Input_MusicKeys[4]),
			.inputWire(max10board_switches[8] && max10Board_GPIO_Input_MusicKeys[4]),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_MusicKeys_s[4])
		);
		UI_TriggerSmoother UIs_MusicKeys5 (
			.clock_50Mhz(CLK_1Khz),
			.inputWire(max10Board_GPIO_Input_MusicKeys[5] && max10Board_GPIO_Input_MusicKeys[5]),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_MusicKeys_s[5])
		);
	wire max10Board_GPIO_Input_PlaySong1_s;
		UI_TriggerSmoother UIs_PlaySong1 (
			.clock_50Mhz(CLK_1Khz),
			//.inputWire(max10Board_GPIO_Input_PlaySong1),
			.inputWire(max10board_switches[0] && max10Board_GPIO_Input_PlaySong1),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_PlaySong1_s)
		);
	wire max10Board_GPIO_Input_PlaySong0_s;
		UI_TriggerSmoother UIs_PlaySong0 (
			.clock_50Mhz(CLK_1Khz),
			//.inputWire(max10Board_GPIO_Input_PlaySong0),
			.inputWire(max10board_switches[1] && max10Board_GPIO_Input_PlaySong0),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_PlaySong0_s)
		);
	wire max10Board_GPIO_Input_MakeRecording_s;
		UI_TriggerSmoother UIs_Makerecording (
			.clock_50Mhz(CLK_1Khz),
			//.inputWire(max10Board_GPIO_Input_MakeRecording),
			.inputWire(max10board_switches[2] && max10Board_GPIO_Input_MakeRecording),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_MakeRecording_s)
		);
	wire max10Board_GPIO_Input_PlayRecording_s;
		UI_TriggerSmoother UIs_PlayRecording (
			.clock_50Mhz(CLK_1Khz),
			//.inputWire(max10Board_GPIO_Input_PlayRecording),
			.inputWire(max10board_switches[3] && max10Board_GPIO_Input_PlayRecording),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_PlayRecording_s)
		);
	wire max10Board_GPIO_Input_BeeMode_s;  //Will be sent to be toggled
		UI_TriggerSmoother UIs_BeeMode (
			.clock_50Mhz(CLK_1Khz),
			//.inputWire(max10Board_GPIO_Input_BeeMode),
			.inputWire(max10board_switches[9] && max10Board_GPIO_Input_BeeMode),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_BeeMode_s)
		);
	wire max10Board_GPIO_Input_BeeMode_s_t; //Smoothed, Toggled
		 UI_ToggleButton UIst_BeeMode( 
			.inputWire(max10Board_GPIO_Input_BeeMode_s),
			.reset_n(systemReset_n),
			.outputWire(max10Board_GPIO_Input_BeeMode_s_t)
		);


	//----------------------------
	//-- Music Keys---------------
	//----------------------------
	//These operate only in the state DoNothing and MakeRecording.  
//	wire [5:0] musicKeysDebugTemp ; //Stores output.  Basically input keys if in current state.
//assign max10Board_LED[0] =  (outputCurrentState[0] == 1 ) ? 1'b1 : 1'b0;
//	assign max10Board_LED[1] =  (outputCurrentState[1] == 1 ) ? 1'b1 : 1'b0;
	wire [7:0] musicKeys_AudioOutput;
	//assign segmentDisplay_DisplayValue = musicKeys_AudioOutput;
	MusicKeysController musicKeysController (
		.CLK_1Khz(CLK_1Khz),
		.CLK_32Khz(CLK_32Khz),
		.reset_n(systemReset_n),
		.currentState(outputCurrentState), //This is controlled by MusicBoxStateController.   
		.input_MusicKey(max10Board_GPIO_Input_MusicKeys_s),
		//.debugString(segmentDisplay_DisplayValue), //This is used to send any data out of the module for testing purposes.  Follows no format.
		.musicKeys_AudioOutput(musicKeys_AudioOutput)
	//	.outputKeyPressed(musicKeysDebugTemp)
	);
	

	////////////////////////////////////////////////////////////
	//------- LIGHT CONTROLLER ------------------------------///
	////////////////////////////////////////////////////////////
	//assign max10Board_LED[5:1] = max10Board_GPIO_Output_MusicKeys_LEDs;
	LEDController lEDController (
		.CLK_50Mhz(max10Board_50MhzClock),
		.CLK_10Khz(CLK_10Khz),
		.CLK_1Khz(CLK_1Khz),
		.reset_n(systemReset_n),
		.currentState(outputCurrentState),
		.input_MusicKey(max10Board_GPIO_Input_MusicKeys_s),

		//--HARDWARE IO FOR LEDs
		.max10Board_GPIO_Output_MusicKeys_LEDs(max10Board_GPIO_Output_MusicKeys_LEDs),
		.max10Board_GPIO_Output_ModeKeys_LEDs(max10Board_GPIO_Output_ModeKeys_LEDs),
		.max10Board_GPIO_Output_SideLEDs(max10Board_GPIO_Output_SideLEDs)
	);


	/////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////
	//------------------------------------
	//------- SDRAM Controller -----------
	//------------------------------------
	reg [24:0]	sdram_inputAddress; //This is the address to loop up
	reg [15:0] 	sdram_inputData; //Data to WRITE (only if writing)
	reg [15:0] 	sdram_outputData; //Data from READ (Only if reading)
	reg 		sdram_isWriting; //If 1, we are WRITING.  if 0, we are READING.
	reg			sdram_inputValid; //Tells the SDRAM to perform the action if high. 
	 
	reg			sdram_outputValid; //Tells modules output data is available on the output.
	reg 		sdram_recievedCommand; //Tells modules it recieved the input.
	reg 		sdram_isBusy; //Tells modules if it is working on something (including internal autorefresh)
	
	assign max10Board_LED[9:5] = outputCurrentState;
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
	wire [7:0] audioOutputStateController;
	MusicBoxStateController musicBoxStateController (
		//--INPUT
		.clock_50Mhz(max10Board_50MhzClock),
		.clock_32Khz(CLK_32Khz),
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
		//--SPI INPUT
		.SPIinput_sample(SPI_ADC_Output_outputSample),
		.SPIInput_ArduinoFreq(arduino_freqSample),
		.SPIInput_ArduinoAmp(arduino_ampSample),
		//--SDRAM Interface
		.sdram_inputAddress(sdram_inputAddress),
		.sdram_writeData(sdram_inputData),
		.sdram_readData(sdram_outputData),
		.sdram_isWriting(sdram_isWriting),
		.sdram_inputValid(sdram_inputValid),
		//--
		.sdram_outputValid(sdram_outputValid),
		.sdram_recievedCommand(sdram_recievedCommand),
		.sdram_isBusy(sdram_isBusy),


		//--AUDIO OUTPUT.  Ranges from 0 to 255.  Rests at 0 when no mode selected
		.outputAudioOutput(audioOutputStateController)
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
	reg [11:0] dacOutputAudio ;
	assign dacOutputAudio= (audioOutputStateController + musicKeys_AudioOutput) * 8; // 256 * 16 = 2^12     Can multiply with smaller number to act as global volume limit.
	//assign segmentDisplay_DisplayValue = dacOutputAudio;

	assign max10Board_LED[1] = max10Board_GPIO_Output_SPI_SCLK;
	assign max10Board_LED[2] = max10Board_GPIO_Output_SPI_SYNC_n;
	assign max10Board_LED[3] = max10Board_GPIO_Output_SPI_DIN;
	//assign max10Board_LED[4] = sdram_outputData;

	SPI_OutputControllerDac sPI_OutputControllerDac (
		//--INPUT
		.clock_50Mhz(max10Board_50MhzClock),
		.clock_1Khz(CLK_1Khz),
		.reset_n(systemReset_n),
		//--CONTROL
		.inputSample(dacOutputAudio), //12 bits that will be sent to the DAC
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
	///////////////////////////////////////////////////////////
	//----------------------------
	//---SPI Input from ADC ------
	//----------------------------
	wire SPI_ADC_Input_sendSample;
	wire [7:0] SPI_ADC_Output_outputSample;
		//assign SPI_ADC_Output_outputSample = testSineGenerator_1Hz;
		//assign segmentDisplay_DisplayValue = dacOutputAudio ; //Ensure it is getting value
	wire SPI_ADC_Output_newSample;
	
	wire [15:0] arduino_freqSample ;
	wire [7:0] arduino_ampSample;

	//assign max10Board_LED[4] = max10Board_GPIO_Input_SPI_SCLK;
	//assign max10Board_LED[5] = max10Board_GPIO_Input_SPI_CS_n;
	//assign max10Board_LED[6] = max10Board_GPIO_Input_SPI_SDO;

	assign segmentDisplay_DisplayValue = song0DataOutput ;// testSineGenerator_1Hz;//= output_DebugString;//arduino_freqSample;
//	assign max10Board_LED = testSineGenerator_1Hz;
	SPI_Arduino sPI_Arduino (
		.reset_n(systemReset_n),
		//.inputLight(max10Board_LED[3]),
		.input_SPI_SCLK(max10Board_GPIO_Input_SPI_SCLK),
		.input_SPI_CS_n(max10Board_GPIO_Input_SPI_CS_n),
		.input_SPI_SDO(max10Board_GPIO_Input_SPI_SDO),

		//--Output from arduino
		.outputFrequencySample(arduino_freqSample),
		.outputAmplitudeSample(arduino_ampSample)

	);
	
//----------------------------
//--------Rom Integrator-----

reg [15:0] song0AccessIndex;
reg [15:0] song0AccessMaxIndex;
reg [15:0] song0DataOutput;

ROMIntegrator rOMIntegrator (
	.CLK_50Mhz(max10Board_50MhzClock),
	.reset_n(systemReset_n),
	.song0AccessIndex(max10board_switches),
	.song0AccessMaxIndex(song0AccessMaxIndex),
	.song0DataOutput(song0DataOutput)
);




	//--DISABLED FOR SPI ARDUINO
	// SPI_InputControllerDac sPI_InputControllerDac(
	// 	//--INPUT
	// 	.clock_50Mhz(max10Board_50MhzClock),
	// 	.reset_n(systemReset_n),
	// 	//--CONTROL
	// 	.sendSample(SPI_ADC_Input_sendSample),
	// 	//--HARDWARE I/O
	// 	.input_SPI_SCLK(max10Board_GPIO_Input_SPI_SCLK),
	// 	.input_SPI_CS_n(max10Board_GPIO_Input_SPI_CS_n),
	// 	.input_SPI_SDO(max10Board_GPIO_Input_SPI_SDO),
	// 	//--OUTPUT
	// 	.outputSample(SPI_ADC_Output_outputSample),
	// 	//--SIGNAL
	// 	.sampleReady(SPI_ADC_Output_newSample)
	// );
	

	wire [7:0] testSineGenerator_1Hz;
	SignalGenerator testSineGenerator(
		.CLK_32KHz(CLK_32Khz),
		.reset_n( systemReset_n),
		.inputFrequency(100),
		.inputAmplitude(255),
		.outputSample(testSineGenerator_1Hz)
	);

	function automatic  [7:0] SignalMultiply255 (input [7:0] a, input [7:0] b);
		return  ( (a * b + 127) * 1/255);
	endfunction


endmodule