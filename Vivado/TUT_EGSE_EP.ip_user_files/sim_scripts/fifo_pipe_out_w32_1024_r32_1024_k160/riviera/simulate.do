onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+fifo_pipe_out_w32_1024_r32_1024_k160  -L xpm -L fifo_generator_v13_2_7 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.fifo_pipe_out_w32_1024_r32_1024_k160 xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure

do {fifo_pipe_out_w32_1024_r32_1024_k160.udo}

run 1000ns

endsim

quit -force
