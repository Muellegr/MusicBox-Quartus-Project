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
    // input logic CLK_32Khz,
	input logic CLK_1Khz,  
    input logic reset_n,
    input logic [4:0] currentState, //This is controlled by MusicBoxStateController.   
    input logic [5:0] input_MusicKey,

    //--OUTPUT IO
    output logic [5:0][2:0] max10Board_GPIO_Output_MusicKeys_LEDs,
    output logic [4:0] max10Board_GPIO_Output_ModeKeys_LEDs

);
    reg [5:0][2:0][7:0] musicKeys_RGBColor; // [KEY] [COLOR] [BITS]
    reg [4:0][7:0] modeKeys_RGBColor; // [KEY] [BITS]
    // { musicKeys_RGBColor[0][2], musicKeys_RGBColor[0][1], musicKeys_RGBColor[0][0] }   for combining back into color

    //LEDs should be all on but at half brightness
    assign musicKeys_RGBColor[0] = {8'd128, 8'd128, 8'd128} ;
    assign musicKeys_RGBColor[1] = {8'd128, 8'd128, 8'd128} ;
    assign musicKeys_RGBColor[2] = {8'd128, 8'd128, 8'd128} ;
    assign musicKeys_RGBColor[3] = {8'd128, 8'd128, 8'd128} ;
    assign musicKeys_RGBColor[4] = {8'd128, 8'd128, 8'd128} ;
    assign musicKeys_RGBColor[5] = {8'd128, 8'd128, 8'd128} ;
    assign modeKeys_RGBColor[0] = 8'd128;
    assign modeKeys_RGBColor[1] = 8'd128;
    assign modeKeys_RGBColor[2] = 8'd128;
    assign modeKeys_RGBColor[3] = 8'd128;
    assign modeKeys_RGBColor[4] = 8'd128;

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

endmodule