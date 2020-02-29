module MusicKeysController ( 
		input logic CLK_32Khz,
		input logic CLK_1Khz,  
		input logic reset_n,
		input logic [4:0] currentState, //This is controlled by MusicBoxStateController.   
		input logic [5:0] input_MusicKey,
		
		output logic [31:0] debugString, //This is used to send any data out of the module for testing purposes.  Follows no format.
		output logic [7:0] musicKeys_AudioOutput
		//Output logic for sending signals to the frequency generator here.  
		//output logic [5:0] outputKeyPressed
		);
		assign musicKeys_AudioOutput = musicKeys_Output[0] + musicKeys_Output[1] + musicKeys_Output[2] + musicKeys_Output[3] + musicKeys_Output[4] + musicKeys_Output[5];

		//assign debugString = noiseFalloffAmplitude[0];
		// //If the music key is held down  AND   current state is doing nothing(0) or playing recording(4).  Used to detect when button changes states.
		// assign outputKeyPressed[0] = (input_MusicKey[0] == 1'b0 && (currentState == 5'd0 || currentState == 5'd4)) * 1'b1;
		// assign outputKeyPressed[1] = (input_MusicKey[1] == 1'b0 && (currentState == 5'd0 || currentState == 5'd4)) * 1'b1;
		// assign outputKeyPressed[2] = (input_MusicKey[2] == 1'b0 && (currentState == 5'd0 || currentState == 5'd4)) * 1'b1;
		// assign outputKeyPressed[3] = (input_MusicKey[3] == 1'b0 && (currentState == 5'd0 || currentState == 5'd4)) * 1'b1;
		// assign outputKeyPressed[4] = (input_MusicKey[4] == 1'b0 && (currentState == 5'd0 || currentState == 5'd4)) * 1'b1;
		// assign outputKeyPressed[5] = (input_MusicKey[5] == 1'b0 && (currentState == 5'd0 || currentState == 5'd4)) * 1'b1;





		reg [5:0][7:0] noiseFalloffAmplitude ; //Set to 0 when not allowed to be playing.  When key is pressed, it goes to max amplitude and falls down to 200 where it stays.  When key is releaed, it falls to 0 after a short time.
		reg [5:0] 	   input_MusicKey_q;
		always_ff @ ( posedge CLK_1Khz) begin
			//If  doing nothing(0) or making recording, we can play sound.  
			if (reset_n == 0 || !(currentState == 5'd0 || currentState == 5'd4)) begin
				noiseFalloffAmplitude[0] <= 0;
				noiseFalloffAmplitude[1] <= 0;
				noiseFalloffAmplitude[2] <= 0;
				noiseFalloffAmplitude[3] <= 0;
				noiseFalloffAmplitude[4] <= 0;
				noiseFalloffAmplitude[5] <= 0;
				//Set last state of the music keys as unpressed (1).
				input_MusicKey_q[0] <= 1;
				input_MusicKey_q[1] <= 1;
				input_MusicKey_q[2] <= 1;
				input_MusicKey_q[3] <= 1;
				input_MusicKey_q[4] <= 1;
				input_MusicKey_q[5] <= 1;
			end
			else begin
				//Update previous state so that next clock, they will store what the input was this clock.
				input_MusicKey_q[0] <= input_MusicKey[0];
				input_MusicKey_q[1] <= input_MusicKey[1];
				input_MusicKey_q[2] <= input_MusicKey[2];
				input_MusicKey_q[3] <= input_MusicKey[3];
				input_MusicKey_q[4] <= input_MusicKey[4];
				input_MusicKey_q[5] <= input_MusicKey[5];

				//If music keys went from one mode to another, AND music key is now 0
					//This detects when music keys goes from unpressed to pressed, nad pressed to unpressed.
					//It will only be 0 when it detects it is pressed.  So this captures the instant the button is held down but ignores the rest of the time while it's held down.
				if (input_MusicKey[0] != input_MusicKey_q[0] && input_MusicKey[0] == 0) begin
					noiseFalloffAmplitude[0] = 8'd255;
				end 
				else if (noiseFalloffAmplitude > 0) begin //If we are not 0
					//Decrement it.  When above 200, it gets decremented by 5.  When between 100 and 200, it gets decremented by 2.   Slightly exponential.  Stops at 0.
					// && input_MusicKey[1] == 0
					noiseFalloffAmplitude[0] = noiseFalloffAmplitude[0] -  ( (noiseFalloffAmplitude[0] > 200 )? 8'd3 : 8'd0) -
												  ( (noiseFalloffAmplitude[0] > 100 && input_MusicKey[0] == 1)? 8'd1 : 8'd0) -
												  ( (noiseFalloffAmplitude[0] > 0   && input_MusicKey[0] == 1)? 8'd1 : 8'd0) ;
				end

				//Button 1
				if (input_MusicKey[1] != input_MusicKey_q[1] && input_MusicKey[1] == 0) begin
					noiseFalloffAmplitude[1] = 8'd255;
				end 
				else if (noiseFalloffAmplitude > 0) begin //If we are not 0
					noiseFalloffAmplitude[1]= noiseFalloffAmplitude[1]-  ( (noiseFalloffAmplitude[1]> 200 )? 8'd3 : 8'd0) -
												  ( (noiseFalloffAmplitude[1]> 100 && input_MusicKey[1]== 1)? 8'd1 : 8'd0) -
												  ( (noiseFalloffAmplitude[1]> 0   && input_MusicKey[1]== 1)? 8'd1 : 8'd0) ;
				end

				//Button 2
				if (input_MusicKey[2] != input_MusicKey_q[2] && input_MusicKey[2] == 0) begin
					noiseFalloffAmplitude[2] = 8'd255;
				end 
				else if (noiseFalloffAmplitude > 0) begin //If we are not 0
					noiseFalloffAmplitude[2]= noiseFalloffAmplitude[2]-  ( (noiseFalloffAmplitude[2]> 200 )? 8'd3 : 8'd0) -
												  ( (noiseFalloffAmplitude[2]> 100 && input_MusicKey[2]== 1)? 8'd1 : 8'd0) -
												  ( (noiseFalloffAmplitude[2]> 0   && input_MusicKey[2]== 1)? 8'd1 : 8'd0) ;
				end

				//Button 3
				if (input_MusicKey[3] != input_MusicKey_q[3] && input_MusicKey[3] == 0) begin
					noiseFalloffAmplitude[3] = 8'd255;
				end 
				else if (noiseFalloffAmplitude > 0) begin //If we are not 0
					noiseFalloffAmplitude[3] = noiseFalloffAmplitude[3] -  ( (noiseFalloffAmplitude[3] > 200 )? 8'd3 : 8'd0) -
												  ( (noiseFalloffAmplitude[3] > 100 && input_MusicKey[3] == 1)? 8'd1 : 8'd0) -
												  ( (noiseFalloffAmplitude[3] > 0   && input_MusicKey[3] == 1)? 8'd1 : 8'd0) ;
				end

				//Button 4
				if (input_MusicKey[4] != input_MusicKey_q[4] && input_MusicKey[4] == 0) begin
					noiseFalloffAmplitude[4] = 8'd255;
				end 
				else if (noiseFalloffAmplitude > 0) begin //If we are not 0
					noiseFalloffAmplitude[4] = noiseFalloffAmplitude[4] -  ( (noiseFalloffAmplitude[4] > 200 )? 8'd3 : 8'd0) -
												  ( (noiseFalloffAmplitude[4] > 100 && input_MusicKey[4] == 1)? 8'd1 : 8'd0) -
												  ( (noiseFalloffAmplitude[4] > 0   && input_MusicKey[4] == 1)? 8'd1 : 8'd0) ;
				end

				//Button 5
				if (input_MusicKey[5] != input_MusicKey_q[5] && input_MusicKey[5] == 0) begin
					noiseFalloffAmplitude[5] = 8'd255;
				end 
				else if (noiseFalloffAmplitude > 0) begin //If we are not 0
					noiseFalloffAmplitude[5] = noiseFalloffAmplitude[5] -  ( (noiseFalloffAmplitude[5] > 200 )? 8'd3 : 8'd0) -
												  ( (noiseFalloffAmplitude[5] > 100 && input_MusicKey[5] == 1)? 8'd1 : 8'd0) -
												  ( (noiseFalloffAmplitude[5] > 0   && input_MusicKey[5] == 1)? 8'd1 : 8'd0) ;
				end

				

			end
		end
		

	//-------
	wire [5:0][7:0] musicKeys_Output;

	//--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
	//--==--==--==--==--==BUTTON 0 SETUP =--==--==--==--==--==--==--==--==
	//--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
	SignalGenerator_Square musicKey0(
		.CLK_32KHz(CLK_32Khz),
		.reset_n( reset_n),
		.inputFrequency(14'd714),
		.inputAmplitude ( noiseFalloffAmplitude[0] / 8'd7),
		.outputSample(musicKeys_Output[0])
	);

	//--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
	//--==--==--==--==--==BUTTON 1 SETUP =--==--==--==--==--==--==--==--==
	//--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
	SignalGenerator_Square musicKey1(
		.CLK_32KHz(CLK_32Khz),
		.reset_n( reset_n),
		.inputFrequency(14'd1428),
		.inputAmplitude ( noiseFalloffAmplitude[1] / 8'd9), //Little more quiet
		.outputSample(musicKeys_Output[1])
	);

	//--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
	//--==--==--==--==--==BUTTON 2 SETUP =--==--==--==--==--==--==--==--==
	//--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
	SignalGenerator_Square musicKey2(
		.CLK_32KHz(CLK_32Khz),
		.reset_n( reset_n),
		.inputFrequency(14'd43),
		.inputAmplitude ( noiseFalloffAmplitude[2] / 8'd7), 
		.outputSample(musicKeys_Output[2])
	);

	//--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
	//--==--==--==--==--==BUTTON 3 SETUP =--==--==--==--==--==--==--==--==
	//--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
	wire [7:0] musicKey3_WavingAmplitude;
	SignalGenerator_Triangle musicKey4(
		.CLK_32KHz(CLK_32Khz),
		.reset_n( reset_n),
		.inputFrequency(14'd600),
		.inputAmplitude ( musicKey3_WavingAmplitude), 
		.outputSample(musicKeys_Output[3])
	);
	SignalGenerator musicKey3_amp(
		.CLK_32KHz(CLK_32Khz),
		.reset_n( reset_n),
		.inputFrequency(14'd443),
		.inputAmplitude ( noiseFalloffAmplitude[3] / 8'd7), 
		.outputSample(musicKey3_WavingAmplitude)
	);

	//--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
	//--==--==--==--==--==BUTTON 4 SETUP =--==--==--==--==--==--==--==--==
	//--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
	wire [7:0] musicKey4_WavingAmplitude;
	wire [7:0] musicKey4_outputa;
	wire [7:0] musicKey4_outputb;
	assign musicKeys_Output[4] = musicKey4_outputa + musicKey4_outputb;
	SignalGenerator_Triangle musicKey4a(
		.CLK_32KHz(CLK_32Khz),
		.reset_n( reset_n),
		.inputFrequency(14'd1300),
		.inputAmplitude ( musicKey4_WavingAmplitude/2), 
		.outputSample(musicKey4_outputa)
	);
	SignalGenerator_Triangle musicKey4b(
		.CLK_32KHz(CLK_32Khz),
		.reset_n( reset_n),
		.inputFrequency(14'd1305),
		.inputAmplitude ( musicKey4_WavingAmplitude/2), 
		.outputSample(musicKey4_outputb)
	);
	SignalGenerator musicKey4_amp(
		.CLK_32KHz(CLK_32Khz),
		.reset_n( reset_n),
		.inputFrequency(14'd743),
		.inputAmplitude ( noiseFalloffAmplitude[4] / 8'd7), 
		.outputSample(musicKey4_WavingAmplitude)
	);

	//--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
	//--==--==--==--==--==BUTTON 5 SETUP =--==--==--==--==--==--==--==--==
	//--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==
	wire [7:0] musicKey5_WavingAmplitude;
	wire [7:0] musicKey5_outputa;
	wire [7:0] musicKey5_outputb;
	assign musicKeys_Output[5] = musicKey5_outputa + musicKey5_outputb;
	SignalGenerator_Triangle musicKey5a(
		.CLK_32KHz(CLK_32Khz),
		.reset_n( reset_n),
		.inputFrequency(14'd1300),
		.inputAmplitude ( musicKey5_WavingAmplitude/2), 
		.outputSample(musicKey5_outputa)
	);
	SignalGenerator_Triangle musicKey5b(
		.CLK_32KHz(CLK_32Khz),
		.reset_n( reset_n),
		.inputFrequency(14'd1305),
		.inputAmplitude ( musicKey5_WavingAmplitude/2), 
		.outputSample(musicKey5_outputb)
	);
	SignalGenerator musicKey5_amp(
		.CLK_32KHz(CLK_32Khz),
		.reset_n( reset_n),
		.inputFrequency(14'd743),
		.inputAmplitude ( noiseFalloffAmplitude[5] / 8'd7), 
		.outputSample(musicKey5_WavingAmplitude)
	);


endmodule