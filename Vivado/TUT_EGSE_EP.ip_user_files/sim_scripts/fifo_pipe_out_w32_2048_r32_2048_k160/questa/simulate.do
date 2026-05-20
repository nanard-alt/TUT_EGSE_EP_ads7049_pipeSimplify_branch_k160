onbreak {quit -f}
onerror {quit -f}

vsim  -lib xil_defaultlib fifo_pipe_out_w32_2048_r32_2048_k160_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {fifo_pipe_out_w32_2048_r32_2048_k160.udo}

run 1000ns

quit -force
