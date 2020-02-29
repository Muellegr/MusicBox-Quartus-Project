/*
This takes in a set of 6 4bit values and displays them on the board.

Displays a decimal value from a single binary value.
If a segment has a leading zero, it will display blank.  The smallest digit will always display a value (0 to 9)  
Instead of for '16' displaying '000016'  it wil display '    16'   

*/

module SevenSegmentParser(
		input logic [19:0] displayValue,
		output logic [5:0][6:0] segmentPins
	); 

	SevenSegmentDisplay sevenSegmentDisplay0(
		.data(SevenSegmentIndexValue(digitValue[0],highestIndex , 5'd0 )),
		.segments(segmentPins[6'd0])
	);
	
	SevenSegmentDisplay sevenSegmentDisplay1(
		.data(SevenSegmentIndexValue(digitValue[1],highestIndex , 5'd1 )),
		.segments(segmentPins[6'd1])
	);
	
	SevenSegmentDisplay sevenSegmentDisplay2(
		.data(SevenSegmentIndexValue(digitValue[2],highestIndex , 5'd2 )),
		.segments(segmentPins[6'd2])
	);
	
	SevenSegmentDisplay sevenSegmentDisplay3(
		.data(SevenSegmentIndexValue(digitValue[3],highestIndex , 5'd3 )),
		.segments(segmentPins[6'd3])
	);
	
	SevenSegmentDisplay sevenSegmentDisplay4(
		.data(SevenSegmentIndexValue(digitValue[4],highestIndex , 5'd4 )),
		.segments(segmentPins[6'd4])
	);
	
	SevenSegmentDisplay sevenSegmentDisplay5(
		.data(SevenSegmentIndexValue(digitValue[5],highestIndex , 5'd5 )),
		.segments(segmentPins[6'd5])
	);
	

	wire [5:0][3:0] digitValue;
			assign digitValue[0] = (displayValue / (1) ) % 10;
			assign digitValue[1] = (displayValue / (10) ) % 10;
			assign digitValue[2] = (displayValue / (100) ) % 10;
			assign digitValue[3] = (displayValue / (1000) ) % 10;
			assign digitValue[4] = (displayValue / (10000) ) % 10;
			assign digitValue[5] = (displayValue / (100000) ) % 10;
			wire [3:0] highestIndex ;
			assign highestIndex = (digitValue[5] > 0) ? 5 :      //If we have index 5, highest is 5, else
								  (digitValue[4] > 0) ? 4 :      //else if highest is 4, highest is 4. 
								  (digitValue[3] > 0) ? 3 :      //ect
								  (digitValue[2] > 0) ? 2 :      
								  (digitValue[1] > 0) ? 1 : 0;


	function automatic reg[3:0] SevenSegmentIndexValue  ( logic[3:0] data, logic[3:0] highestIndex ,logic [4:0] indexPosition );
			SevenSegmentIndexValue = (indexPosition == highestIndex || indexPosition < highestIndex) ? data : 4'd10;
		endfunction
endmodule