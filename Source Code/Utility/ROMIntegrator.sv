/*
Given a bunch of output data and array indeces requested for many systems.  This updates those at a steady rate.
*/



module ROMIntegrator (
    input logic CLK_50Mhz,
    input logic reset_n,

    //--DATA
    //--SONG 0
    input  logic [15:0] song0AccessIndex,
    input  logic [15:0] song0AccessMaxIndex,
    output logic [15:0]  song0DataOutput, //8bits

    //--SONG 1
    input  logic [15:0] song1AccessIndex,
    input  logic [15:0] song1AccessMaxIndex,
    output logic [15:0]  song1DataOutput, //8bits

    //--Bee
    input  logic [15:0] BeeAccessIndex,
    input  logic [15:0] BeeAccessMaxIndex,
    output logic [15:0]  BeeDataOutput //8bits

);

    reg [7:0] counter;

    wire [7:0] counterLimit;

    assign counterLimit = 4;

    reg [15:0] romAddress;
    reg [15:0] romOutput;

    always_ff @(posedge CLK_50Mhz, negedge reset_n) begin
        if (reset_n == 0) begin
            counter <= 8'd0;
            romAddress <= 16'd0;
        end
        else begin
            //Handle counter
            romAddress <= 0; 
            song0DataOutput <= romOutput;
            if (counter == counterLimit) begin counter <= 0; end
            else begin counter <= counter + 1; end

            //Because address lags, rowOutput needs a clock cyle before it is looking at the address for it.
            // case (counter) 
            //     8'd0 : begin romAddress <= 1 ; end
            //     8'd1 : begin romAddress <= 0    ; song0DataOutput <= romOutput; end
            //    // 8'd1 : begin romAddress <= song1AccessIndex   + song0AccessMaxIndex   ; song0DataOutput <= romOutput; end
            //     8'd2 : begin romAddress <= BeeAccessIndex     + song1AccessMaxIndex   ; song1DataOutput <= romOutput; end //Song 1
            //     8'd3 : begin romAddress <= song0AccessIndex                           ; BeeDataOutput   <= romOutput; end //Bee Noise signal generator
            //     // 8'd4 : ; //High def sine?
            //     // 8'd5 : ; //Unused?
            //     // 8'd6 : ; //Unused?


            //     default : ; //ERROR
            // endcase
        end

    end


    
    INTEL_Rom1 intelRom(
        .address (romAddress), 
        .clock (CLK_50Mhz), 
        .q (romOutput)
    );




endmodule