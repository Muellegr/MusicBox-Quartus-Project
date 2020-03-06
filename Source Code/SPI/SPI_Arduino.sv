/*
Communicates with an Arduino at an unknown clock speed in a slave only mode.  We recieve sync, clock, and data.
Clock is normally high until it sends is bits.
Sync is normally high until it goes low to indicate we are active.

Frequency is hardcoded to have the 14th bit position to be 1.
Amplitude is hard coded to have the 15th bit to be one.

*/
module SPI_Arduino( 
	input logic reset_n,
    //--SPI INPUT HARDWARE PINS
    input logic input_SPI_SCLK, //Clock
	input logic input_SPI_CS_n, //Active low input.  
	input logic input_SPI_SDO,  //Serial data input.  Comes in MSB first.  Falling edge.

    //--OUTPUT SAMPLES.  
    output logic [13:0] outputFrequencySample,
    output logic [ 7:0] outputAmplitudeSample
);
    reg [15:0] workingInputSample; //This is being shifted 1 bit at a time when in use
    reg [4:0] spiInput_DataCounter; //How we know when to stop
    reg recievingSample; //State flag for collecting bits.  
	reg chipselect_q;//for edge detecting CS when it goes low
    
    reg [5:0] bitCounter;
    always_ff @ (posedge input_SPI_SCLK, negedge reset_n, posedge input_SPI_CS_n) begin
        //If resetting, set to initial state.
        if (reset_n == 0) begin
            workingInputSample <= 16'd0;
            spiInput_DataCounter <= 5'd0;
            chipselect_q <= 1;
            recievingSample <= 0;
            outputFrequencySample <= 0;
            bitCounter <= 0;
        end
        //If the SPI SCLK caused it, update the output
        else if (input_SPI_CS_n == 1) begin
             if (workingInputSample[14] == 1 && bitCounter == 16) begin
                outputFrequencySample <= workingInputSample[12:0];
                
            end
            else if (workingInputSample[15] == 1 &&  bitCounter == 16) begin 
                outputAmplitudeSample <= workingInputSample[7:0];
            end
            bitCounter <= 0;
            workingInputSample <= 0;
            
        end
        //Else we saw a rising edge
        else begin
            workingInputSample <= (workingInputSample << 1) + input_SPI_SDO;
            bitCounter <= bitCounter + 1;
        end
    end

endmodule