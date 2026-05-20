// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
// Date        : Wed May 20 17:42:24 2026
// Host        : IRLW245164 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/3utransat-k160/TUT_EGSE_EP_ads7049_pipeSimplify_branch_k160_clone/Vivado/TUT_EGSE_EP.gen/sources_1/ip/clk_wiz_0_k160/clk_wiz_0_k160_stub.v
// Design      : clk_wiz_0_k160
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k160tffg676-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_0_k160(clk_out1, clk_out2, locked, clk_in1_p, clk_in1_n)
/* synthesis syn_black_box black_box_pad_pin="clk_out1,clk_out2,locked,clk_in1_p,clk_in1_n" */;
  output clk_out1;
  output clk_out2;
  output locked;
  input clk_in1_p;
  input clk_in1_n;
endmodule
