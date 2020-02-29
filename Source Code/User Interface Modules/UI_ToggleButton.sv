//This module toggles the input wire from on to off.  

module UI_ToggleButton ( 
		input logic inputWire,
		input logic reset_n,
		output logic outputWire);

    always_ff @(negedge inputWire, negedge reset_n) begin
        if (reset_n == 0) begin
            outputWire <= 1'd0;
        end
        else if (inputWire == 1'b0) begin outputWire <= ~outputWire; end
    end
endmodule