start_gui
create_project TUT_EGSE_EP C:/3Utransat/TUT_EGSE_EP/Vivado -part xc7a75tfgg484-1
set_property target_language VHDL [current_project]
add_files -norecurse {C:/3Utransat/TUT_EGSE_EP/sources/Interface/FSM_read_config.vhd C:/3Utransat/TUT_EGSE_EP/sources/EP/spectrum_FSM.vhd C:/3Utransat/TUT_EGSE_EP/sources_OK/okWireOut.v C:/3Utransat/TUT_EGSE_EP/sources/EP/FIR_filter.vhd C:/3Utransat/TUT_EGSE_EP/sources_OK/okWireIn.v C:/3Utransat/TUT_EGSE_EP/sources/Interface/Injection.vhd C:/3Utransat/TUT_EGSE_EP/sources/EP/spectrum.vhd C:/3Utransat/TUT_EGSE_EP/sources/Interface/FSM_raw_data.vhd C:/3Utransat/TUT_EGSE_EP/sources/EP/rams_sp_rf.vhd C:/3Utransat/TUT_EGSE_EP/sources/EP/EP.vhd C:/3Utransat/TUT_EGSE_EP/sources/EP/Energy_level.vhd C:/3Utransat/TUT_EGSE_EP/sources/UT_EGSE_EP_Package.vhd C:/3Utransat/TUT_EGSE_EP/sources/CDC/Fast_to_Slow_CDC.vhd C:/3Utransat/TUT_EGSE_EP/sources_OK/okLibrary.vhd C:/3Utransat/TUT_EGSE_EP/sources_OK/okPipeIn.v C:/3Utransat/TUT_EGSE_EP/sources_OK/okPipeOut.v C:/3Utransat/TUT_EGSE_EP/sources_OK/okCoreHarness.v C:/3Utransat/TUT_EGSE_EP/sources/ADC/Rx_fe.vhd C:/3Utransat/TUT_EGSE_EP/sources/TOP/TUT_EGSE.vhd C:/3Utransat/TUT_EGSE_EP/sources/EP/rams_sp_nc.vhd}
add_files -fileset constrs_1 -norecurse C:/3Utransat/TUT_EGSE_EP/sources/TOP/xem7310.xdc
create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name raw_data_fifo
set_property -dict [list \
  CONFIG.Component_Name {raw_data_fifo} \
  CONFIG.Input_Data_Width {32} \
] [get_ips raw_data_fifo]
generate_target {instantiation_template} [get_files c:/3Utransat/TUT_EGSE_EP/Vivado/TUT_EGSE_EP.srcs/sources_1/ip/raw_data_fifo/raw_data_fifo.xci]
generate_target all [get_files  c:/3Utransat/TUT_EGSE_EP/Vivado/TUT_EGSE_EP.srcs/sources_1/ip/raw_data_fifo/raw_data_fifo.xci]
catch { config_ip_cache -export [get_ips -all raw_data_fifo] }
export_ip_user_files -of_objects [get_files c:/3Utransat/TUT_EGSE_EP/Vivado/TUT_EGSE_EP.srcs/sources_1/ip/raw_data_fifo/raw_data_fifo.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] c:/3Utransat/TUT_EGSE_EP/Vivado/TUT_EGSE_EP.srcs/sources_1/ip/raw_data_fifo/raw_data_fifo.xci]
launch_runs raw_data_fifo_synth_1 -jobs 4
create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name clk_wiz_0
set_property -dict [list \
  CONFIG.CLKIN1_JITTER_PS {50.0} \
  CONFIG.CLKOUT1_JITTER {234.276} \
  CONFIG.CLKOUT1_PHASE_ERROR {187.805} \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {20.00} \
  CONFIG.CLKOUT2_JITTER {184.861} \
  CONFIG.CLKOUT2_PHASE_ERROR {187.805} \
  CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {60.00} \
  CONFIG.CLKOUT2_USED {true} \
  CONFIG.MMCM_CLKFBOUT_MULT_F {25.500} \
  CONFIG.MMCM_CLKIN1_PERIOD {5.000} \
  CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
  CONFIG.MMCM_CLKOUT0_DIVIDE_F {51.000} \
  CONFIG.MMCM_CLKOUT1_DIVIDE {17} \
  CONFIG.MMCM_DIVCLK_DIVIDE {5} \
  CONFIG.NUM_OUT_CLKS {2} \
  CONFIG.PRIM_IN_FREQ {200.00} \
  CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
  CONFIG.USE_RESET {false} \
] [get_ips clk_wiz_0]
generate_target {instantiation_template} [get_files c:/3Utransat/TUT_EGSE_EP/Vivado/TUT_EGSE_EP.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci]
generate_target all [get_files  c:/3Utransat/TUT_EGSE_EP/Vivado/TUT_EGSE_EP.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci]
generate_target all [get_files  c:/3Utransat/TUT_EGSE_EP/Vivado/TUT_EGSE_EP.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci]