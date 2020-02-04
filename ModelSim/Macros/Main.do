project compileall
vsim work.MusicBox_Main
delete wave *
add wave * 

noforce max10Board_50MhzClock

force systemReset_n 0
force systemReset_n 0 10ns, 1 20ns

run 20ns

force systemReset_n 0 10ns, 1 20ns

run 20ns


#force max10Board_GPIO_Input_SPI_CS_n 1
force max10Board_GPIO_Input_SPI_SDO 1
force SPI_ADC_Input_sendSample 0
force max10Board_50MhzClock 0  0,  1  10ns -repeat 20ns
run 100us

force SPI_ADC_Input_sendSample 1
force max10Board_GPIO_Input_SPI_SDO 0
run 5 us
force SPI_ADC_Input_sendSample 0
run 11.64 us
force max10Board_GPIO_Input_SPI_SDO 1
run 33.28us
force max10Board_GPIO_Input_SPI_SDO 0
run 50us



##force SPI_Output_WriteSample 12'b101010101010
#force max10Board_GPIO_Input_PlaySong0_s 1
#run 100us
#force max10Board_GPIO_Input_PlaySong0_s 0
#run 100us
#force max10Board_GPIO_Input_PlaySong0_s 1
##force SPI_Output_SendSample 0
#run 5us
##force SPI_Output_SendSample 1
#run 50us


#noforce INPUT_Reset_n
#noforce trueReset_n



