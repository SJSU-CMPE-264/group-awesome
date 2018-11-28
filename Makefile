waveform:
	iverilog -o test -c fp_files.txt 
	vvp test
	