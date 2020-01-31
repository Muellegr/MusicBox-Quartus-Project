/*

Must send 16 bits.
 X  X  0  0  D  D  D  D  D  D  D  D  D  D  D  D
15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0

The two 0s configure the state : Basically tell it the system is on.
*/
module SPI_OutputControllerDac( 
		input logic clock_50Mhz,
		input logic clock_1Khz,
		input logic reset_n,
		
			//--Configured as output.  These outputs connect directly to the GPIO pins.
		output logic output_SPI_SCLK,
		output logic output_SPI_SYNC_n,
		output logic output_SPI_DIN,
		
		input logic [11:0] inputSample, //12 bits that will be sent to the DAC
		input logic sendSample_n, //Active low signal.  If the system is not busy, it will begin sending the sample out.
		
		output logic isBusy,
		output logic transmitComplete //Goes high for 71Khz when this completes the signal
		
		);
		
		//--CLOCK GENERATOR
		//--The DAC will need to send at least 16 bits in 22050Hz.  
			//For safety, it will be designed to send 32 bits in the same time.
			// (50*10^6 / 2) * (1/x) = 22050*32
				//x = 35,    outputFreq :  714285 or 71.2Khz
		wire CLK_71Khz ;
		ClockGenerator clockGenerator_71Khz (
			.inputClock(clock_50Mhz),
			.reset_n(reset_n),
			.outputClock(CLK_71Khz)
		);
		defparam	clockGenerator_71Khz.BitsNeeded = 8; //Must be able to count up to InputClockEdgesToCount.  
		defparam	clockGenerator_71Khz.InputClockEdgesToCount = 35;
		
		
		reg [4:0]  currentState;
		reg [15:0] counter; //Temporary use counter.  
		reg [11:0] writeSample; //When the state detects we are ready to write, this is set.  
		reg		   writeBit; //Individual bit we are writing
		//This enable sinputSample to change while we are writing. 
		
		
		
		assign output_SPI_SCLK = CLK_71Khz;
		//Sync is held high while we are in state 0.  
		assign output_SPI_SYNC_n = (currentState == 0 );
		assign output_SPI_DIN = writeBit * (currentState != 0);
		assign isBusy = !(currentState == 0);
		
		always_ff@(negedge CLK_71Khz, negedge reset_n) begin
			if (reset_n == 0) begin
				currentState <= 0;
				writeBit <= 0;
				counter <= 0;
				transmitComplete <= 0;
			end
			//--Not sending data.  Wait until we get a request for information.
			else if (currentState == 0) begin
				//We are now ready to send the signal
				transmitComplete <= 0;
				if (sendSample_n == 0) begin
					//$display("%m Good start sequence bro! %d", $stime);
					$display("%m Beginning SPI output transmit %b", $writeSample);
					writeSample <= inputSample;
					currentState <= 1;
					writeBit <= 0;
				end
			end
			//--Beginning sending data.
				//First 2 bits are DO NOT CARE.
				//Next 2 bits are mode - 0 0
			else if (currentState == 1) begin
				transmitComplete <= 0;
				if (counter == 3) begin
					counter <= 0;
					currentState <= 2;
					
					//This takes 1 clock cycle to become the actual output.  
					writeBit <= writeSample[11];
					writeSample <= writeSample << 1;
				end
				else begin
					counter <= counter + 1;
				end
			end
			else if (currentState == 2) begin
				//Transmit complete : All bits sent
				if (counter == 15) begin
					$display("%m 	System complete");
					transmitComplete <= 1;
					counter <= 0;
					currentState <= 0;
					writeBit<=0;
					
				end
				//Continue sending bits
				else begin
					$display("%m Sending bit : %d  Remaining Sample : %b!", writeBit, writeSample);
					$display("%m 	Counter : %d!", counter);
					writeBit <= writeSample[11];
					writeSample <= writeSample << 1;
					
					transmitComplete <= 0;
					counter <= counter + 1;
				end
			end
			else if (currentState == 3) begin
				//Transmit complete : All bits sent
				if (counter == 1) begin
					$display("%m 	System complete");
					transmitComplete <= 1;
					counter <= 0;
					currentState <= 0;
					writeBit<=0;
					
				end
				//Continue sending bits
				else begin
					$display("%m Sending bit : %d  Remaining Sample : %b!", writeBit, writeSample);
					$display("%m 	Counter : %d!", counter);
					//writeBit <= writeSample[11];
					//writeSample <= writeSample << 1;
					
					//transmitComplete <= 0;
					counter <= counter + 1;
				end
			end
			
			
		end
	

		
endmodule