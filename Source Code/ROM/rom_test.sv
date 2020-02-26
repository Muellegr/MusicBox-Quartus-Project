/* 
 *	Filename: rom_top_level.sv
 * Author: Tristan Luther
 * Date: 2/25/2020
 * Purpose: Testbench for Using ROM DE-10 Eval Board
 */

module rom_test(
    max10Board_50MhzClock,
	max10Board_GPIO_Output_SPI_SCLK,
	max10Board_GPIO_Output_SPI_SYNC_n,
	max10Board_GPIO_Output_SPI_DIN
);
	 
// Large Vairable Declerations
///////// GPIO SPI Output to Dac
input  wire	max10Board_50MhzClock;
output wire max10Board_GPIO_Output_SPI_SCLK; //Data clock per bit
output wire max10Board_GPIO_Output_SPI_SYNC_n; //Low when sending data
output wire max10Board_GPIO_Output_SPI_DIN; //Data bits
reg [31:0] counter = 0; // Counter regulator for scaling the clock
	 
// Clock Generators
	wire CLK_1Khz ;
	ClockGenerator clockGenerator_1Khz (
		.inputClock(max10Board_50MhzClock),
		.reset_n(systemReset_n),
		.outputClock(CLK_1Khz)
	);
		defparam	clockGenerator_1Khz.BitsNeeded = 15; //Must be able to count up to InputClockEdgesToCount.  
		defparam	clockGenerator_1Khz.InputClockEdgesToCount = 25000;
	
//ROM Access	
reg [7:0] addr = 8'b0; // Register to hold the ROM address
reg [7:0] q;	// Register to hold the data from ROM to be sent to the DAC
		
songRom s1(
	.address (addr), 
	.clock (max10Board_50MhzClock), 
	.q (q)
);

//SPI Output to DAC
wire SPI_Output_SendSample_n; // Hardware IO
assign SPI_Output_SendSample_n = 0;
wire 		SPI_Output_isBusy; // High when sending a message
wire 		SPI_Output_transmitComplete;// This goes high briefly when complete

//--This connects with the module that controls the DAC.  The DAC sends signals to the speaker. 
reg [32:0] c1;

SPI_OutputControllerDac dac1(
	.clock_50Mhz (max10Board_50MhzClock), 
	.clock_1Khz (CLK_1Khz), 
	.reset_n (systemReset_n), 
	.output_SPI_SCLK (max10Board_GPIO_Output_SPI_SCLK), 
	.output_SPI_SYNC_n (max10Board_GPIO_Output_SPI_SYNC_n), 
	.output_SPI_DIN (max10Board_GPIO_Output_SPI_DIN), 
	.inputSample (q), 
	.sendSample_n (SPI_Output_SendSample_n), 
	.isBusy (SPI_Output_isBusy), 
	.transmitComplete (SPI_Output_transmitComplete)
);

//Move though the memory addresses as the clock cycles go (WILL NEED TO BE SLOWED FOR PROPER AUDIO: This is a test for ROM values)
always @(posedge max10Board_50MhzClock)
begin
 counter <= counter + 1; //Counter for scaling the 50MHz
 if(counter == 25000000)
  begin
	addr <= addr + 1; //Traverse though the address
	counter <= 0;
  end
  
end

endmodule
