/* 
 *	Filename: debouncer.sv
 * Author: Tristan Luther
 * Date: 1/18/2020
 * Purpose: Debounce Tactile Button Inputs
 */
 module debouncer(
	input CLK,
	input switch_in,
	output reg state,
	output trans_up,
	output trans_dn
 );
 
 //Sync the switch to the clock
 reg sync_0, sync_1;
 
 always @(posedge CLK)
 begin
	sync_0 = switch_in;
 end
 
 always @(posedge CLK)
 begin
	sync_1 = sync_0;
 end
 
 //Debouncing action
 reg [16:0] count;
 wire idle = (state == sync_1);
 wire finished = &count; //only true when all bits of count are 1
 
 always @(posedge CLK)
 begin
	if(idle)
	begin
		count <= 0;
	end
	else
	begin
		count <= count + 1;
		if(finished)
		begin
			state <= ~state;
		end
	end
 end
 
 assign trans_dn = ~idle & finished & ~state;
 assign trans_up = ~idle & finished & state;
 
 endmodule
	