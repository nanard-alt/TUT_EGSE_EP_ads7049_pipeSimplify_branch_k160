vlib work
vlib riviera

vlib riviera/xpm
vlib riviera/xil_defaultlib

vmap xpm riviera/xpm
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xpm  -sv2k12 "+incdir+../../../ipstatic" \
"D:/Xilinx/Vivado/2022.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/Xilinx/Vivado/2022.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93  \
"D:/Xilinx/Vivado/2022.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../ipstatic" \
"../../../../TUT_EGSE_EP.gen/sources_1/ip/clk_wiz_0_k160/clk_wiz_0_k160_clk_wiz.v" \
"../../../../TUT_EGSE_EP.gen/sources_1/ip/clk_wiz_0_k160/clk_wiz_0_k160.v" \

vlog -work xil_defaultlib \
"glbl.v"

