vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib

vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xil_defaultlib  -incr -mfcu  \
"../../../../TUT_EGSE_EP.gen/sources_1/ip/fifo_pipe_out_w32_4096_r32_4096_k160/sim/fifo_pipe_out_w32_4096_r32_4096_k160.v" \


vlog -work xil_defaultlib \
"glbl.v"

