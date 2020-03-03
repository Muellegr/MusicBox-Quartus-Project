//This module controls the light intensity at any moment.  It performs it's own logic but may recieve outside logic as well.
/*

STATE VALUES FOR CURRENTSTATE
    00 - 0000 - Do Nothing
    01 - 0001 - Play Song 0
    02 - 0010 - Play Song 1
    03 - 0011 - Play Recording
    04 - 0100 - Make Recording

    MODEKEYS 0 : Song0
             1 : Song1
             2 : Make Recording
             3 : Play Recording
             4 : Bee Mode
*/
module LEDController( 
     input logic CLK_50Mhz,
    input logic CLK_10Khz,
    // input logic CLK_32Khz,
	input logic CLK_1Khz,  
    input logic reset_n,
    input logic [4:0] currentState, //This is controlled by MusicBoxStateController.   
    input logic [5:0] input_MusicKey,

    //--OUTPUT IO
    output logic [5:0][2:0] max10Board_GPIO_Output_MusicKeys_LEDs,
    output logic [4:0] max10Board_GPIO_Output_ModeKeys_LEDs

);
    //Combinational logic determining if a light is on? 

    reg [5:0][2:0][7:0] musicKeys_RGBColor; // [KEY] [COLOR] [BITS]
    reg [2:0][7:0] musicKeys_RGBColor_RGBDivider; // 0-10 intensity for color
    reg [4:0][7:0] modeKeys_RGBColor; // [KEY] [BITS]
    reg [5:0] input_MusicKey_q ; //Last state of the button.
    //Lights are always being told to do things, but if we aren't in the mode then we just ignore them.  


    always_ff @(posedge CLK_10Khz, negedge reset_n) begin
        if (reset_n == 1'd0) begin
            musicKeys_RGBColor[0] <= {8'd0, 8'd0, 8'd0} ;
            musicKeys_RGBColor[1] <= {8'd0, 8'd0, 8'd0} ;
            musicKeys_RGBColor[2] <= {8'd0, 8'd0, 8'd0} ;
            musicKeys_RGBColor[3] <= {8'd0, 8'd0, 8'd0} ;
            musicKeys_RGBColor[4] <= {8'd0, 8'd0, 8'd0} ;
            musicKeys_RGBColor[5] <= {8'd0, 8'd0, 8'd0} ;

            modeKeys_RGBColor[0] <= 8'd0; //Song 0
            modeKeys_RGBColor[1] <= 8'd0; //Song 1
            modeKeys_RGBColor[2] <= 8'd0; //Make Recording
            modeKeys_RGBColor[3] <= 8'd0; //Play Recording
            modeKeys_RGBColor[4] <= 8'd0; //Bee Mode

            input_MusicKey_q[0] <= 1'd1; //Active low
            input_MusicKey_q[1] <= 1'd1; //Active low
            input_MusicKey_q[2] <= 1'd1; //Active low
            input_MusicKey_q[3] <= 1'd1; //Active low
            input_MusicKey_q[4] <= 1'd1; //Active low

            musicKeys_RGBColor_RGBDivider[0] <= 8'd1;
            musicKeys_RGBColor_RGBDivider[1] <= 8'd1;
            musicKeys_RGBColor_RGBDivider[2] <= 8'd1;
        end 
        else begin
            //State machine that forces LEDs on and off
            input_MusicKey_q <= input_MusicKey; //Edge detection
            if (currentState == 0 || currentState == 4) begin //DO NOTHING or Make Recording (Bee Mode)
                //------------------------------------------------------------------------------------------
                //Make R brighter
                if (input_MusicKey_q[0] != input_MusicKey[0] && input_MusicKey [0] == 0 ) begin
                    if (musicKeys_RGBColor_RGBDivider[0] < 25) begin musicKeys_RGBColor_RGBDivider[0] <=  musicKeys_RGBColor_RGBDivider[0] + 3; end
                end 
                //Make R dimmer
                if (input_MusicKey_q[3] != input_MusicKey[3] && input_MusicKey [3] == 0 ) begin
                    if (musicKeys_RGBColor_RGBDivider[0] > 1) begin musicKeys_RGBColor_RGBDivider[0] <=  musicKeys_RGBColor_RGBDivider[0] - 3; end
                end 

                  //Make G brighter
                if (input_MusicKey_q[1] != input_MusicKey[1] && input_MusicKey [1] == 0 ) begin
                    if (musicKeys_RGBColor_RGBDivider[1] < 25) begin musicKeys_RGBColor_RGBDivider[1] <=  musicKeys_RGBColor_RGBDivider[1] + 3; end
                end 
                //Make G dimmer
                if (input_MusicKey_q[4] != input_MusicKey[4] && input_MusicKey [4] == 0 ) begin
                    if (musicKeys_RGBColor_RGBDivider[1] > 1) begin musicKeys_RGBColor_RGBDivider[1] <=  musicKeys_RGBColor_RGBDivider[1] - 3; end
                end 

                  //Make R brighter
                if (input_MusicKey_q[2] != input_MusicKey[2] && input_MusicKey [3] == 0 ) begin
                    if (musicKeys_RGBColor_RGBDivider[2] < 25) begin musicKeys_RGBColor_RGBDivider[2] <=  musicKeys_RGBColor_RGBDivider[2] + 3; end
                end 
                //Make R dimmer
                if (input_MusicKey_q[5] != input_MusicKey[5] && input_MusicKey [5] == 0 ) begin
                    if (musicKeys_RGBColor_RGBDivider[2] > 1) begin musicKeys_RGBColor_RGBDivider[2] <=  musicKeys_RGBColor_RGBDivider[2] - 3; end
                end 
                 //------------------------------------------------------------------------------------------
                musicKeys_RGBColor[0][0] <= horizontalWave[0] / (musicKeys_RGBColor_RGBDivider[0] ); //R
                musicKeys_RGBColor[0][1] <= horizontalWave[0] / (musicKeys_RGBColor_RGBDivider[1]); //G
                musicKeys_RGBColor[0][2] <= horizontalWave[0] / (musicKeys_RGBColor_RGBDivider[2] ); //B

                musicKeys_RGBColor[1][0] <= horizontalWave[1] / (musicKeys_RGBColor_RGBDivider[0] ); //R
                musicKeys_RGBColor[1][1] <= horizontalWave[1] / (musicKeys_RGBColor_RGBDivider[1] ); //G
                musicKeys_RGBColor[1][2] <= horizontalWave[1] / (musicKeys_RGBColor_RGBDivider[2] ); //B

                musicKeys_RGBColor[2][0] <= horizontalWave[2] / (musicKeys_RGBColor_RGBDivider[0] ); //R
                musicKeys_RGBColor[2][1] <= horizontalWave[2] / (musicKeys_RGBColor_RGBDivider[1]); //G
                musicKeys_RGBColor[2][2] <= horizontalWave[2] / (musicKeys_RGBColor_RGBDivider[2] ); //B

                musicKeys_RGBColor[3][0] <= horizontalWave[0] / (musicKeys_RGBColor_RGBDivider[0] ); //R
                musicKeys_RGBColor[3][1] <= horizontalWave[0] / (musicKeys_RGBColor_RGBDivider[1] );//G
                musicKeys_RGBColor[3][2] <= horizontalWave[0] / (musicKeys_RGBColor_RGBDivider[2] ); //B

                musicKeys_RGBColor[4][0] <= horizontalWave[1] / (musicKeys_RGBColor_RGBDivider[0] ); //R
                musicKeys_RGBColor[4][1] <= horizontalWave[1] / (musicKeys_RGBColor_RGBDivider[1] ); //G
                musicKeys_RGBColor[4][2] <= horizontalWave[1] / (musicKeys_RGBColor_RGBDivider[2] ); //B

                musicKeys_RGBColor[5][0] <= horizontalWave[2] / (musicKeys_RGBColor_RGBDivider[0] ); //R
                musicKeys_RGBColor[5][1] <= horizontalWave[2] / (musicKeys_RGBColor_RGBDivider[1] );//G
                musicKeys_RGBColor[5][2] <= horizontalWave[2] / (musicKeys_RGBColor_RGBDivider[2] ); //B
                  //------------------------------------------------------------------------------------------
                modeKeys_RGBColor[4] <= 8'd0; //Bee Mode
                  //------------------------------------------------------------------------------------------
                if (currentState == 0) begin
                    modeKeys_RGBColor[0] <= horizontalWave[3] / 2;
                    modeKeys_RGBColor[1] <= horizontalWave[4] / 2; //Song 1
                    modeKeys_RGBColor[2] <= horizontalWave[3] / 2; //Make Recording
                    modeKeys_RGBColor[3] <= horizontalWave[4] / 2; //Play Recording
                end
                else if (currentState == 4) begin //MAKING a recording
                    modeKeys_RGBColor[0] <= 8'd0; //Song 0
                    modeKeys_RGBColor[1] <= 8'd0; //Song 1
                    modeKeys_RGBColor[2] <= 8'd255; //Make Recording
                    modeKeys_RGBColor[3] <= 8'd0; //Play Recording
                end
            end

            //------------------------------------------------------------------------------------------
            else if (currentState == 1) begin //SONG 0
                musicKeys_RGBColor[0] <= {8'd0, 8'd0, 8'd0} ;
                musicKeys_RGBColor[1] <= {8'd0, 8'd0, 8'd0} ;
                musicKeys_RGBColor[2] <= {8'd0, 8'd0, 8'd0} ;
                musicKeys_RGBColor[3] <= {8'd0, 8'd0, 8'd0} ;
                musicKeys_RGBColor[4] <= {8'd0, 8'd0, 8'd0} ;
                musicKeys_RGBColor[5] <= {8'd0, 8'd0, 8'd0} ;
                modeKeys_RGBColor[0] <= 8'd255; //Song 0
                modeKeys_RGBColor[1] <= 8'd0; //Song 1
                modeKeys_RGBColor[2] <= 8'd0; //Make Recording
                modeKeys_RGBColor[3] <= 8'd0; //Play Recording
                modeKeys_RGBColor[4] <= 8'd0; //Bee Mode
            end
            //------------------------------------------------------------------------------------------
            else if (currentState == 2) begin //SONG 1
                musicKeys_RGBColor[0] <= {8'd0, 8'd0, 8'd0} ;
                musicKeys_RGBColor[1] <= {8'd0, 8'd0, 8'd0} ;
                musicKeys_RGBColor[2] <= {8'd0, 8'd0, 8'd0} ;
                musicKeys_RGBColor[3] <= {8'd0, 8'd0, 8'd0} ;
                musicKeys_RGBColor[4] <= {8'd0, 8'd0, 8'd0} ;
                musicKeys_RGBColor[5] <= {8'd0, 8'd0, 8'd0} ;

                modeKeys_RGBColor[0] <= 8'd0; //Song 0
                modeKeys_RGBColor[1] <= 8'd255; //Song 1
                modeKeys_RGBColor[2] <= 8'd0; //Make Recording
                modeKeys_RGBColor[3] <= 8'd0; //Play Recording
                modeKeys_RGBColor[4] <= 8'd0; //Bee Mode
            end 
            //------------------------------------------------------------------------------------------
            else if (currentState == 3) begin //PLAY RECORDING
                musicKeys_RGBColor[0] <= {8'd0, 8'd0, 8'd0} ;
                musicKeys_RGBColor[1] <= {8'd0, 8'd0, 8'd0} ;
                musicKeys_RGBColor[2] <= {8'd0, 8'd0, 8'd0} ;
                musicKeys_RGBColor[3] <= {8'd0, 8'd0, 8'd0} ;
                musicKeys_RGBColor[4] <= {8'd0, 8'd0, 8'd0} ;
                musicKeys_RGBColor[5] <= {8'd0, 8'd0, 8'd0} ;

                modeKeys_RGBColor[0] <= 8'd0; //Song 0
                modeKeys_RGBColor[1] <= 8'd0; //Song 1
                modeKeys_RGBColor[2] <= 8'd0; //Make Recording
                modeKeys_RGBColor[3] <= 8'd255; //Play Recording
                modeKeys_RGBColor[4] <= 8'd0; //Bee Mode
            end

        end

    end

   



    wire [5:0][7:0] horizontalWave;
     SignalGenerator_Triangle signalGenerator_midi0Signal(
		.CLK_32KHz(CLK_10Khz),
		.reset_n( reset_n),
		.inputFrequency(14'd1),
        .inputAmplitude(8'd255),
        .inputOffset(8'd0),
		.outputSample(horizontalWave[0])
	);

     SignalGenerator_Triangle signalGenerator_midi1Signal(
		.CLK_32KHz(CLK_10Khz),
		.reset_n( reset_n),
		.inputFrequency(14'd1),
        .inputAmplitude(8'd255),
        .inputOffset(8'd15),
		.outputSample(horizontalWave[1])
	);

     SignalGenerator_Triangle signalGenerator_midi2Signal(
		.CLK_32KHz(CLK_10Khz),
		.reset_n( reset_n),
		.inputFrequency(14'd1),
        .inputAmplitude(8'd255),
        .inputOffset(8'd30),
		.outputSample(horizontalWave[2])
	);

     SignalGenerator_Triangle signalGenerator_midi3Signal(
		.CLK_32KHz(CLK_10Khz),
		.reset_n( reset_n),
		.inputFrequency(14'd1),
        .inputAmplitude(8'd255),
        .inputOffset(8'd45),
		.outputSample(horizontalWave[3])
	);
    SignalGenerator_Triangle signalGenerator_midi4Signal(
		.CLK_32KHz(CLK_10Khz),
		.reset_n( reset_n),
		.inputFrequency(14'd1),
        .inputAmplitude(8'd255),
        .inputOffset(8'd60),
		.outputSample(horizontalWave[4])
	);
     SignalGenerator_Triangle signalGenerator_midi5Signal(
		.CLK_32KHz(CLK_10Khz),
		.reset_n( reset_n),
		.inputFrequency(14'd1),
        .inputAmplitude(8'd255),
        .inputOffset(8'd75),
		.outputSample(horizontalWave[5])
	);




    //Not sure how I will change light color.  3 counters?
    // MIDI BUTTON LAYOUT ON PANEL
    // [0] [1] [2]  [S0] [S1] [B]
    // [3] [4] [5]  [MR] [PR] 
    //--MIDI 0
    rgb_led rgb_led_MIDI0 (
        .pwm_clk(CLK_50Mhz),
        .duty_red(  musicKeys_RGBColor[0][0]),
        .duty_green(musicKeys_RGBColor[0][1]),
        .duty_blue( musicKeys_RGBColor[0][2]),
        .invert(1'd0),
        //--HARDWARE LED OUTPUT
        .PWM_PIN_R(max10Board_GPIO_Output_MusicKeys_LEDs[0][0]),
        .PWM_PIN_G(max10Board_GPIO_Output_MusicKeys_LEDs[0][1]),
        .PWM_PIN_B(max10Board_GPIO_Output_MusicKeys_LEDs[0][2])
    );
    //--MIDI 1
    rgb_led rgb_led_MIDI1 (
        .pwm_clk(CLK_50Mhz),
        .duty_red(  musicKeys_RGBColor[1][0]),
        .duty_green(musicKeys_RGBColor[1][1]),
        .duty_blue( musicKeys_RGBColor[1][2]),
        .invert(1'd0),
        //--HARDWARE LED OUTPUT
        .PWM_PIN_R(max10Board_GPIO_Output_MusicKeys_LEDs[1][0]),
        .PWM_PIN_G(max10Board_GPIO_Output_MusicKeys_LEDs[1][1]),
        .PWM_PIN_B(max10Board_GPIO_Output_MusicKeys_LEDs[1][2])
    );
    //--MIDI 2
    rgb_led rgb_led_MIDI2 (
        .pwm_clk(CLK_50Mhz),
        .duty_red(  musicKeys_RGBColor[2][0]),
        .duty_green(musicKeys_RGBColor[2][1]),
        .duty_blue( musicKeys_RGBColor[2][2]),
        .invert(1'd0),
        //--HARDWARE LED OUTPUT
        .PWM_PIN_R(max10Board_GPIO_Output_MusicKeys_LEDs[2][0]),
        .PWM_PIN_G(max10Board_GPIO_Output_MusicKeys_LEDs[2][1]),
        .PWM_PIN_B(max10Board_GPIO_Output_MusicKeys_LEDs[2][2])
    );
    //--MIDI 3
    rgb_led rgb_led_MIDI3 (
        .pwm_clk(CLK_50Mhz),
        .duty_red(  musicKeys_RGBColor[3][0]),
        .duty_green(musicKeys_RGBColor[3][1]),
        .duty_blue( musicKeys_RGBColor[3][2]),
        .invert(1'd0),
        //--HARDWARE LED OUTPUT
        .PWM_PIN_R(max10Board_GPIO_Output_MusicKeys_LEDs[3][0]),
        .PWM_PIN_G(max10Board_GPIO_Output_MusicKeys_LEDs[3][1]),
        .PWM_PIN_B(max10Board_GPIO_Output_MusicKeys_LEDs[3][2])
    );
    //--MIDI 4
    rgb_led rgb_led_MIDI4 (
        .pwm_clk(CLK_50Mhz),
        .duty_red(  musicKeys_RGBColor[4][0]),
        .duty_green(musicKeys_RGBColor[4][1]),
        .duty_blue( musicKeys_RGBColor[4][2]),
        .invert(1'd0),
        //--HARDWARE LED OUTPUT
        .PWM_PIN_R(max10Board_GPIO_Output_MusicKeys_LEDs[4][0]),
        .PWM_PIN_G(max10Board_GPIO_Output_MusicKeys_LEDs[4][1]),
        .PWM_PIN_B(max10Board_GPIO_Output_MusicKeys_LEDs[4][2])
    );
    //--MIDI 5
    rgb_led rgb_led_MIDI5 (
        .pwm_clk(CLK_50Mhz),
        .duty_red(  musicKeys_RGBColor[5][0]),
        .duty_green(musicKeys_RGBColor[5][1]),
        .duty_blue( musicKeys_RGBColor[5][2]),
        .invert(1'd0),
        //--HARDWARE LED OUTPUT
        .PWM_PIN_R(max10Board_GPIO_Output_MusicKeys_LEDs[5][0]),
        .PWM_PIN_G(max10Board_GPIO_Output_MusicKeys_LEDs[5][1]),
        .PWM_PIN_B(max10Board_GPIO_Output_MusicKeys_LEDs[5][2])
    );

    //----------------
    //--BUTTONS

     rgb_led rgb_led_Song0 (
        .pwm_clk(CLK_50Mhz),
        .duty_red(  8'd0),
        .duty_green(modeKeys_RGBColor[0]),
        .duty_blue( 8'd0),
        .invert(1'd0),
        //--HARDWARE LED OUTPUT
        //.PWM_PIN_R(),
        .PWM_PIN_G(max10Board_GPIO_Output_ModeKeys_LEDs[0]),
        //.PWM_PIN_B(max10Board_GPIO_Output_MusicKeys_LEDs[5][2])
    );

    rgb_led rgb_led_Song1 (
        .pwm_clk(CLK_50Mhz),
        .duty_red(  8'd0),
        .duty_green(modeKeys_RGBColor[1]),
        .duty_blue( 8'd0),
        .invert(1'd0),
        //--HARDWARE LED OUTPUT
        //.PWM_PIN_R(),
        .PWM_PIN_G(max10Board_GPIO_Output_ModeKeys_LEDs[1]),
        //.PWM_PIN_B(max10Board_GPIO_Output_MusicKeys_LEDs[5][2])
    );

    rgb_led rgb_led_MakeRecording (
        .pwm_clk(CLK_50Mhz),
        .duty_red(  8'd0),
        .duty_green(modeKeys_RGBColor[2]),
        .duty_blue( 8'd0),
        .invert(1'd0),
        //--HARDWARE LED OUTPUT
        //.PWM_PIN_R(),
        .PWM_PIN_G(max10Board_GPIO_Output_ModeKeys_LEDs[2]),
        //.PWM_PIN_B(max10Board_GPIO_Output_MusicKeys_LEDs[5][2])
    );

    rgb_led rgb_led_PlayRecording (
        .pwm_clk(CLK_50Mhz),
        .duty_red(  8'd0),
        .duty_green(modeKeys_RGBColor[3]),
        .duty_blue( 8'd0),
        .invert(1'd0),
        //--HARDWARE LED OUTPUT
        //.PWM_PIN_R(),
        .PWM_PIN_G(max10Board_GPIO_Output_ModeKeys_LEDs[3]),
        //.PWM_PIN_B(max10Board_GPIO_Output_MusicKeys_LEDs[5][2])
    );

    rgb_led rgb_led_BeeMode (
        .pwm_clk(CLK_50Mhz),
        .duty_red(  8'd0),
        .duty_green(modeKeys_RGBColor[4]),
        .duty_blue( 8'd0),
        .invert(1'd0),
        //--HARDWARE LED OUTPUT
        //.PWM_PIN_R(),
        .PWM_PIN_G(max10Board_GPIO_Output_ModeKeys_LEDs[4]),
        //.PWM_PIN_B(max10Board_GPIO_Output_MusicKeys_LEDs[5][2])
    );

    function automatic  [7:0] SineWaveOffset (input [7:0] inputWave, input [7:0] offset);
		return  ((inputWave + offset) - ( (inputWave + offset > 255 ) ? (inputWave + offset - 255)*2 : 0 ))  ;


        //If input+offset is past 255, we need to subtract      (base + offset) - 255


	endfunction		
endmodule