/*
Given a bunch of output data and array indeces requested for many systems.  This updates those at a steady rate.



Each address points to 256 bits.

WORKAROUND

I still point at an 8bit address, however this modifies it.

ADDRESS / 32 = ROM address
(ADDRESS / 32) % 32 = POSITION ADDRESS

B31 248/8 = 31, this is the 31st byte at ROM address 0.

B32 At 256, this points to byte 0 at ROM address 1.
B33 At 262, points to byte 1 at rom address 1.

So localAddress/32 = ROM ADDRESS
   localAddress%32 = ACCESS ACCRESS


   reg [15:0] trueRomAddress = (romAddress / 32); //Division rounds down
   reg [ 5:0] trueIndexAddress = (romAddress % 32); //0-31 range.  this*8 = index of first bit.  
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

	reg [31:0] romAddress;
	reg [255:0] romOutput;

	//--Points to correct address
	reg [15:0] trueRomAddress;
	assign trueRomAddress = (romAddress / 32); //Division rounds down
	reg [ 5:0] trueIndexAddress;
	assign trueIndexAddress = (romAddress % 32); //0-31 range.  this*8 = index of first bit.  
	reg [7:0] trueRomOutput;
	assign trueRomOutput = romOutput[(trueIndexAddress*8) +: 8];   //Selects the range of 8 bits for use

	always_ff @(posedge CLK_50Mhz, negedge reset_n) begin
		if (reset_n == 0) begin
			counter <= 8'd0;
			romAddress <= 16'd0;
		end
		else begin
			//Handle counter
		//	romAddress <= song0AccessIndex; 
		//	song0DataOutput <= romOutput;
			if (counter == counterLimit) begin counter <= 0; end
			else begin counter <= counter + 1; end

			// //Because address lags, rowOutput needs a clock cyle before it is looking at the address for it.
			case (counter) 
				//These take 2 clock cycles to before RAM is looking at the correct address.  
				8'd0 : begin romAddress <= 64999 + song0AccessIndex ; end //song0AccessIndex
				8'd1 : begin romAddress <= (song0AccessMaxIndex) + song1AccessIndex ; end
				//255 254 253 252  251 250 249 248
				8'd2 : begin	romAddress <= (song1AccessMaxIndex) + BeeAccessIndex	 ; 
								song0DataOutput <= trueRomOutput; end
				8'd3 : begin	song1DataOutput <= trueRomOutput; end //Song 1
				8'd4 : begin	BeeDataOutput   <= trueRomOutput; end //Bee Noise signal generator
			  //8'd5 : begin romAddress <= song0AccessIndex						   ; BeeDataOutput   <= romOutput; end //Bee Noise signal generator
				// 8'd4 : ; //High def sine?
				// 8'd5 : ; //Unused?
				// 8'd6 : ; //Unused?


				default : ; //ERROR
			endcase
		end

	end


	
	INTEL_Rom1 intelRom(
		.address (trueRomAddress), 
		.clock (CLK_50Mhz), 
		.q (romOutput)
	);




endmodule