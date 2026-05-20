-makelib xcelium_lib/xpm -sv \
  "D:/Xilinx/Vivado/2022.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "D:/Xilinx/Vivado/2022.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "D:/Xilinx/Vivado/2022.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../TUT_EGSE_EP.gen/sources_1/ip/clk_wiz_0_k160/clk_wiz_0_k160_clk_wiz.v" \
  "../../../../TUT_EGSE_EP.gen/sources_1/ip/clk_wiz_0_k160/clk_wiz_0_k160.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

