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

force max10Board_50MhzClock 0  0,  1  10ns -repeat 20ns
run 100ns

force SPI_Output_WriteSample 12'b111111111111
run 1us
force SPI_Output_SendSample 1
run 5us
force SPI_Output_SendSample 0
run 5us
force SPI_Output_SendSample 1
run 50us


#noforce INPUT_Reset_n
#noforce trueReset_n