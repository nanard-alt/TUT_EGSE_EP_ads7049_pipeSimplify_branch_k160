transcript file questa_tut_egse_transcript.log
transcript on

set SCRIPT_NX_ROOT "C:/3utransat-k160/TUT_EGSE_EP_ads7049_pipeSimplify_branch_k160/script_NX"
set SRC_NX        "$SCRIPT_NX_ROOT/sources_NX"
set SRC_SIM       "$SCRIPT_NX_ROOT/sources_simulation"
set QUESTA_DIR    "$SCRIPT_NX_ROOT/Questa"
set NX_LIB_ULTRA  "$QUESTA_DIR/nxLibrary-Ultra.vhdp"

cd $QUESTA_DIR

if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

if {[file exists nx]} {
    vdel -lib nx -all
}
vlib nx
vmap nx nx

if {[file exists "$NX_LIB_ULTRA"]} {
    vcom -2008 -work nx "$NX_LIB_ULTRA"
} else {
    echo "ERROR: NanoXplore Ultra simulation library not found: $NX_LIB_ULTRA"
    quit -code 1
}

file copy -force "$SRC_SIM/coef_HEX_V2.txt" "$QUESTA_DIR/coef_HEX_V2.txt"
if {[file exists "$SRC_SIM/Signal_ADC.txt"]} {
    file copy -force "$SRC_SIM/Signal_ADC.txt" "$QUESTA_DIR/Signal_ADC.txt"
} elseif {[file exists "C:/3utransat-k160/TUT_EGSE_EP_ads7049_pipeSimplify_branch_k160/sources_Simulation/file/Signal_ADC.txt"]} {
    file copy -force "C:/3utransat-k160/TUT_EGSE_EP_ads7049_pipeSimplify_branch_k160/sources_Simulation/file/Signal_ADC.txt" "$QUESTA_DIR/Signal_ADC.txt"
} elseif {[file exists "C:/3utransat-k160/TUT_EGSE_EP_ads7049_pipeSimplify_branch_k160/Vivado/TUT_EGSE_EP.ip_user_files/mem_init_files/Signal_ADC.txt"]} {
    file copy -force "C:/3utransat-k160/TUT_EGSE_EP_ads7049_pipeSimplify_branch_k160/Vivado/TUT_EGSE_EP.ip_user_files/mem_init_files/Signal_ADC.txt" "$QUESTA_DIR/Signal_ADC.txt"
} else {
    echo "ERROR: Signal_ADC.txt not found"
    quit -code 1
}

vcom -2008 "$QUESTA_DIR/FrontPanel_stub.vhd"

vcom -2008 "$SRC_NX/UT_EGSE_EP_Utils.vhd"
vcom -2008 "$SRC_NX/UT_EGSE_EP_Package.vhd"
vcom -2008 "$SRC_NX/CDC/Fast_to_Slow_CDC.vhd"
vcom -2008 "$SRC_NX/CDC/Fast_to_Slow_CDC_lite.vhd"
vcom -2008 "$SRC_NX/EP/rams_sp_rf.vhd"
vcom -2008 "$SRC_NX/EP/FIR_filter.vhd"
vcom -2008 "$SRC_NX/EP/gain.vhd"
vcom -2008 "$SRC_NX/EP/Energy_level.vhd"
vcom -2008 "$SRC_NX/EP/detect_standard_energy.vhd"
vcom -2008 "$SRC_NX/EP/spectrum_FSM.vhd"
vcom -2008 "$SRC_NX/EP/spectrum.vhd"
vcom -2008 "$SRC_NX/EP/cycle_spectrum.vhd"
vcom -2008 "$SRC_NX/EP/EP.vhd"
vcom -2008 "$SRC_NX/Interface/fifo_sync.vhd"
vcom -2008 "$SRC_NX/Interface/spectrum_serializer.vhd"
vcom -2008 "$SRC_NX/Interface/Injection.vhd"
vcom -2008 "$SRC_NX/Interface/FSM_read_config.vhd"
vcom -2008 "$SRC_NX/ADC/Rx_fe_ads7049_and.vhd"
vcom -2008 "$SRC_NX/DAC/DAC121S101_Driver.vhd"
vcom -2008 "$SRC_NX/DAC/remote_DAC121S01_driver.vhd"
vcom -2008 "$SRC_NX/DAC/Top_DAC121S101_Driver.vhd"
vcom -2008 "$SRC_NX/TOP/TUT_EGSE.vhd"

vcom -2008 "$SRC_SIM/ADS7049_Emulators.vhd"
vcom -2008 "$SRC_SIM/OBC_Emulator.vhd"
vcom -2008 "$SRC_SIM/testbench.vhd"

vsim -voptargs=+acc work.testbench

add wave -divider "Top clock reset"
add wave -radix binary sim:/testbench/i_sys_clk
add wave -radix binary sim:/testbench/i_reset
add wave -radix hexadecimal sim:/testbench/i_reg_global

add wave -divider "Config FIFO model"
add wave -radix binary sim:/testbench/o_pipe_in_config_rd_en
add wave -radix binary sim:/testbench/i_pipe_in_config_empty
add wave -radix binary sim:/testbench/i_pipe_in_config_valid
add wave -radix hexadecimal sim:/testbench/i_pipe_in_config_dout
add wave -radix unsigned sim:/testbench/i_pipe_in_config_data_count

add wave -divider "ADS7049 interface"
add wave -radix binary sim:/testbench/o_sck
add wave -radix binary sim:/testbench/o_cs_n
add wave -radix binary sim:/testbench/i_sdi

add wave -divider "OBC serial spectrum"
add wave -radix binary sim:/testbench/o_spectrum_clk
add wave -radix binary sim:/testbench/o_spectrum_sof
add wave -radix binary sim:/testbench/o_spectrum_wr_en
add wave -radix binary sim:/testbench/o_spectrum_bit
add wave -radix binary sim:/testbench/o_spectrum_sd_clk
add wave -radix binary sim:/testbench/o_spectrum_sd_sof
add wave -radix binary sim:/testbench/o_spectrum_sd_wr_en
add wave -radix binary sim:/testbench/o_spectrum_sd_bit

run 5 ms



