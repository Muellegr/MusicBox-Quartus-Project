/*
Taking in N bits with a unknown clock.

max10Board_GPIO_Input_SPI_CS_n : INPUT OR OUTPUT from FPGA perspective
We are given clock, we are given data

Up to us to route information

*/
module SPI_Arduino( 
    // input logic CLK_50Mhz,
    // input logic CLK_32Khz,
	// input logic CLK_1Khz,  
	input logic reset_n,
    output logic inputLight,
    //--SPI INPUT HARDWARE PINS
    input logic input_SPI_SCLK, //Clock
	input logic input_SPI_CS_n, //Active low input.  
	input logic input_SPI_SDO,  //Serial data input.  Comes in MSB first.  Falling edge.

    

    //--OUTPUT SAMPLES.  
    output logic [13:0] outputFrequencySample,
    output logic [ 7:0] outputAmplitudeSample
);
    assign inputLight = recievingSample;



    reg [15:0] workingInputSample; //This is being shifted 1 bit at a time when in use
    reg [4:0] spiInput_DataCounter; //How we know when to stop
    reg recievingSample; //State flag for collecting bits.  
    reg chipselect_q;//for edge detecting CS when it goes low
    //assign outputFrequencySample = workingInputSample; //Debug, show it moving.  Connected to segment display value currently.
    // always_ff @ (posedge input_SPI_SCLK, negedge reset_n) begin
    //     //If resetting, set to initial state.
    //     if (reset_n == 0) begin
    //         workingInputSample <= 16'd0;
    //         spiInput_DataCounter <= 5'd0;
    //         chipselect_q <= 1;
    //         recievingSample <= 0;
    //         outputFrequencySample <= 0;
    //     end
    //     //If not resetting..
    //     else begin
    //         chipselect_q <= input_SPI_CS_n; //chipSelect_q  detects last state of CS.  This enables edge detection.
    //         //State 0 : If we detect an edge to CS AND CS is low, that means we detected the falling edge. 
    //             //If recievingSample is 0, that also means we are not doing anything.
    //         if (chipselect_q != input_SPI_CS_n && input_SPI_CS_n == 0 && recievingSample == 0) begin 
    //             recievingSample <= 1; //Set flag
    //             workingInputSample <= input_SPI_SDO; //On CS going low, data is available.  Set it now.  
    //             spiInput_DataCounter <= spiInput_DataCounter + 1; //Increment counter.  At the end of counting to 16, this is set to 0. 
    //         end
    //         //We detected CS going low and have started looking at the data, but have not reached the end.
    //             //May be off 1 clock cycle.  
    //         else if (recievingSample == 1 && spiInput_DataCounter < 5'd16) begin
    //             //Shift current result over by 1 bit, and add the data pin to it. 
    //             workingInputSample <= (workingInputSample << 1) + input_SPI_SDO;
    //             spiInput_DataCounter <= spiInput_DataCounter + 1;
    //         end 
    //         //If we reached end
    //         else if (recievingSample == 1 && spiInput_DataCounter == 5'd16) begin 
    //             //Assign actual output value here
                
    //              if (workingInputSample[13] == 0) begin
    //                 outputFrequencySample <= workingInputSample[12:0];
    //              end
    //              else begin
    //                 outputAmplitudeSample <= workingInputSample;
    //              end
    //              workingInputSample <= 0;
    //             recievingSample <= 0; //We are no longer recieving, next clock we can start again
    //             spiInput_DataCounter <= 0; //Set counter back to 0
                
    //         end
    //     end 
    // end
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
            //If the 14th bit is set to 0, that indicates it is a frequency
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




        // else if 
        // else begin
        //     if (spiInput_DataCounter == 15) begin
        //         //END
        //          outputFrequencySample <= workingInputSample;
        //     end
        //     else begin
        //         workingInputSample <= (workingInputSample < 1) + input_SPI_SDO;
        //         spiInput_DataCounter <= spiInput_DataCounter + 1;
        //     end

        // end
   // end

endmodule