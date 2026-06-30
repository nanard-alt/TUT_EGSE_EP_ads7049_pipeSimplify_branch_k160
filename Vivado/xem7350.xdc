############################################################################
# XEM7350 - Xilinx constraints file
#
# Pin mappings for the XEM7350.  Use this as a template and comment out 
# the pins that are not used in your design.  (By default, map will fail
# if this file contains constraints for signals not in your design).
#
# Copyright (c) 2004-2021 Opal Kelly Incorporated
############################################################################
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS True [current_design]

############################################################################
## FrontPanel Host Interface
############################################################################
set_property PACKAGE_PIN F23 [get_ports {okHU[0]}]
set_property PACKAGE_PIN H23 [get_ports {okHU[1]}]
set_property PACKAGE_PIN J25 [get_ports {okHU[2]}]
set_property SLEW FAST [get_ports {okHU[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {okHU[*]}]

set_property PACKAGE_PIN F22 [get_ports {okUH[0]}]
set_property PACKAGE_PIN G24 [get_ports {okUH[1]}]
set_property PACKAGE_PIN J26 [get_ports {okUH[2]}]
set_property PACKAGE_PIN G26 [get_ports {okUH[3]}]
set_property PACKAGE_PIN C23 [get_ports {okUH[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {okUH[*]}]

set_property PACKAGE_PIN B21 [get_ports {okUHU[0]}]
set_property PACKAGE_PIN C21 [get_ports {okUHU[1]}]
set_property PACKAGE_PIN E22 [get_ports {okUHU[2]}]
set_property PACKAGE_PIN A20 [get_ports {okUHU[3]}]
set_property PACKAGE_PIN B20 [get_ports {okUHU[4]}]
set_property PACKAGE_PIN C22 [get_ports {okUHU[5]}]
set_property PACKAGE_PIN D21 [get_ports {okUHU[6]}]
set_property PACKAGE_PIN C24 [get_ports {okUHU[7]}]
set_property PACKAGE_PIN C26 [get_ports {okUHU[8]}]
set_property PACKAGE_PIN D26 [get_ports {okUHU[9]}]
set_property PACKAGE_PIN A24 [get_ports {okUHU[10]}]
set_property PACKAGE_PIN A23 [get_ports {okUHU[11]}]
set_property PACKAGE_PIN A22 [get_ports {okUHU[12]}]
set_property PACKAGE_PIN B22 [get_ports {okUHU[13]}]
set_property PACKAGE_PIN A25 [get_ports {okUHU[14]}]
set_property PACKAGE_PIN B24 [get_ports {okUHU[15]}]
set_property PACKAGE_PIN G21 [get_ports {okUHU[16]}]
set_property PACKAGE_PIN E23 [get_ports {okUHU[17]}]
set_property PACKAGE_PIN E21 [get_ports {okUHU[18]}]
set_property PACKAGE_PIN H22 [get_ports {okUHU[19]}]
set_property PACKAGE_PIN D23 [get_ports {okUHU[20]}]
set_property PACKAGE_PIN J21 [get_ports {okUHU[21]}]
set_property PACKAGE_PIN K22 [get_ports {okUHU[22]}]
set_property PACKAGE_PIN D24 [get_ports {okUHU[23]}]
set_property PACKAGE_PIN K23 [get_ports {okUHU[24]}]
set_property PACKAGE_PIN H24 [get_ports {okUHU[25]}]
set_property PACKAGE_PIN F24 [get_ports {okUHU[26]}]
set_property PACKAGE_PIN D25 [get_ports {okUHU[27]}]
set_property PACKAGE_PIN J24 [get_ports {okUHU[28]}]
set_property PACKAGE_PIN B26 [get_ports {okUHU[29]}]
set_property PACKAGE_PIN H26 [get_ports {okUHU[30]}]
set_property PACKAGE_PIN E26 [get_ports {okUHU[31]}]
set_property SLEW FAST [get_ports {okUHU[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {okUHU[*]}]

set_property PACKAGE_PIN R26 [get_ports {okAA}]
set_property IOSTANDARD LVCMOS33 [get_ports {okAA}]


create_clock -name okUH0 -period 9.920 [get_ports {okUH[0]}]

set_input_delay -add_delay -max -clock [get_clocks {okUH0}]  8.000 [get_ports {okUH[*]}]
set_input_delay -add_delay -min -clock [get_clocks {okUH0}] 10.000 [get_ports {okUH[*]}]
set_multicycle_path -setup -from [get_ports {okUH[*]}] 2

set_input_delay -add_delay -max -clock [get_clocks {okUH0}]  8.000 [get_ports {okUHU[*]}]
set_input_delay -add_delay -min -clock [get_clocks {okUH0}]  2.000 [get_ports {okUHU[*]}]
set_multicycle_path -setup -from [get_ports {okUHU[*]}] 2

set_output_delay -add_delay -max -clock [get_clocks {okUH0}]  2.000 [get_ports {okHU[*]}]
set_output_delay -add_delay -min -clock [get_clocks {okUH0}]  -0.500 [get_ports {okHU[*]}]

set_output_delay -add_delay -max -clock [get_clocks {okUH0}]  2.000 [get_ports {okUHU[*]}]
set_output_delay -add_delay -min -clock [get_clocks {okUH0}]  -0.500 [get_ports {okUHU[*]}]

#create_clock -name sys_clk -period 5.000 [get_ports sys_clkp] 

############################################################################
## System Clock
############################################################################
set_property IOSTANDARD LVDS [get_ports {sys_clkp}]
set_property PACKAGE_PIN AC4 [get_ports {sys_clkp}]

set_property IOSTANDARD LVDS [get_ports {sys_clkn}]
set_property PACKAGE_PIN AC3 [get_ports {sys_clkn}]

create_clock -name sys_clk -period 5 [get_ports sys_clkp]

set_clock_groups -name async_frontpanel_virtual -asynchronous \
    -group [get_clocks virt_okUH0] \
    -group [get_clocks -include_generated_clocks okUH0]

set_clock_groups -name async_frontpanel_user -asynchronous \
    -group [get_clocks -include_generated_clocks okUH0] \
    -group [get_clocks -include_generated_clocks sys_clk]

# LEDs #####################################################################
set_property PACKAGE_PIN T24 [get_ports {led[0]}]
set_property PACKAGE_PIN T25 [get_ports {led[1]}]
set_property PACKAGE_PIN R25 [get_ports {led[2]}]
set_property PACKAGE_PIN P26 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]

# ADC comment: ADC IO constraints disabled/commented out in VHDL.
# ADS7049 ADC 1
# set_property -dict {PACKAGE_PIN AF24 IOSTANDARD LVCMOS33} [get_ports {o_sck[0]}]
# set_property -dict {PACKAGE_PIN Y22  IOSTANDARD LVCMOS33} [get_ports {o_cs_n[0]}]
# set_property -dict {PACKAGE_PIN AA22 IOSTANDARD LVCMOS33 PULLUP true} [get_ports {i_sdi[0]}]

# ADS7049 ADC 2
# set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports {o_sck[1]}]
# set_property -dict {PACKAGE_PIN C16 IOSTANDARD LVCMOS33} [get_ports {o_cs_n[1]}]
# set_property -dict {PACKAGE_PIN J19 IOSTANDARD LVCMOS33 PULLUP true} [get_ports {i_sdi[1]}]

# ADS7049 ADC 3
# set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports {o_sck[2]}]
# set_property -dict {PACKAGE_PIN F15 IOSTANDARD LVCMOS33} [get_ports {o_cs_n[2]}]
# set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33 PULLUP true} [get_ports {i_sdi[2]}]

# ADS7049 ADC 4
# set_property -dict {PACKAGE_PIN G10 IOSTANDARD LVCMOS33} [get_ports {o_sck[3]}]
# set_property -dict {PACKAGE_PIN H9  IOSTANDARD LVCMOS33} [get_ports {o_cs_n[3]}]
# set_property -dict {PACKAGE_PIN G9  IOSTANDARD LVCMOS33 PULLUP true} [get_ports {i_sdi[3]}]

# ADS7049 ADC 5
# set_property -dict {PACKAGE_PIN F19 IOSTANDARD LVCMOS33} [get_ports {o_sck[4]}]
# set_property -dict {PACKAGE_PIN H19 IOSTANDARD LVCMOS33} [get_ports {o_cs_n[4]}]
# set_property -dict {PACKAGE_PIN E20 IOSTANDARD LVCMOS33 PULLUP true} [get_ports {i_sdi[4]}]

# ADS7049 ADC 6
# set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports {o_sck[5]}]
# set_property -dict {PACKAGE_PIN F10 IOSTANDARD LVCMOS33} [get_ports {o_cs_n[5]}]
# set_property -dict {PACKAGE_PIN G11 IOSTANDARD LVCMOS33 PULLUP true} [get_ports {i_sdi[5]}]

# ADS7049 ADC 7
# set_property -dict {PACKAGE_PIN J11 IOSTANDARD LVCMOS33} [get_ports {o_sck[6]}]
# set_property -dict {PACKAGE_PIN F9  IOSTANDARD LVCMOS33} [get_ports {o_cs_n[6]}]
# set_property -dict {PACKAGE_PIN J10 IOSTANDARD LVCMOS33 PULLUP true} [get_ports {i_sdi[6]}]



# DAC 1
set_property -dict {PACKAGE_PIN AC26 IOSTANDARD LVCMOS12} [get_ports {o_DAC_SCLK[0]}]   ; # CLK_DAC_1   FMC-F11 HA_08_N
set_property -dict {PACKAGE_PIN AB26 IOSTANDARD LVCMOS12} [get_ports {o_DAC_SYNC_n[0]}] ; # SYNCH_DAC_1 FMC-F10 HA_08_P
set_property -dict {PACKAGE_PIN W25  IOSTANDARD LVCMOS12} [get_ports {o_DAC_DIN[0]}]    ; # DIN_DAC_1   FMC-F13 HA_12_P
set_property -dict {PACKAGE_PIN AF25 IOSTANDARD LVCMOS12} [get_ports {o_DAC_on_off[0]}] ; # ON_1        FMC-F08 HA_04_N

# DAC 2
set_property -dict {PACKAGE_PIN F20 IOSTANDARD LVCMOS12} [get_ports {o_DAC_SCLK[1]}]    ; # CLK_DAC_2   FMC-H08 LA_02_N
set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS12} [get_ports {o_DAC_SYNC_n[1]}]  ; # SYNCH_DAC_2 FMC-H10 LA_04_P
set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS12} [get_ports {o_DAC_DIN[1]}]     ; # DIN_DAC_2   FMC-H07 LA_02_P
set_property -dict {PACKAGE_PIN D20 IOSTANDARD LVCMOS12} [get_ports {o_DAC_on_off[1]}]  ; # ON_2        FMC-H11 LA_04_N

# DAC 3
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS12} [get_ports {o_DAC_SCLK[2]}]    ; # CLK_DAC_3   FMC-H19 LA_15_P
set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS12} [get_ports {o_DAC_SYNC_n[2]}]  ; # SYNCH_DAC_3 FMC-H20 LA_15_N
set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS12} [get_ports {o_DAC_DIN[2]}]     ; # DIN_DAC_3   FMC-H17 LA_11_N
set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS12} [get_ports {o_DAC_on_off[2]}]  ; # ON_3        FMC-H22 LA_19_P

# DAC 4
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS12} [get_ports {o_DAC_SCLK[3]}]    ; # CLK_DAC_4   FMC-H29 LA_24_N
set_property -dict {PACKAGE_PIN G12 IOSTANDARD LVCMOS12} [get_ports {o_DAC_SYNC_n[3]}]  ; # SYNCH_DAC_4 FMC-H31 LA_28_P
set_property -dict {PACKAGE_PIN H14 IOSTANDARD LVCMOS12} [get_ports {o_DAC_DIN[3]}]     ; # DIN_DAC_4   FMC-H28 LA_24_P
set_property -dict {PACKAGE_PIN F12 IOSTANDARD LVCMOS12} [get_ports {o_DAC_on_off[3]}]  ; # ON_4        FMC-H32 LA_28_N

# DAC 5
set_property -dict {PACKAGE_PIN H18 IOSTANDARD LVCMOS12} [get_ports {o_DAC_SCLK[4]}]
set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS12} [get_ports {o_DAC_SYNC_n[4]}]
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS12} [get_ports {o_DAC_DIN[4]}]
set_property -dict {PACKAGE_PIN A19 IOSTANDARD LVCMOS12} [get_ports {o_DAC_on_off[4]}]

# DAC 6
set_property -dict {PACKAGE_PIN A9  IOSTANDARD LVCMOS12} [get_ports {o_DAC_SCLK[5]}]
set_property -dict {PACKAGE_PIN A8  IOSTANDARD LVCMOS12} [get_ports {o_DAC_SYNC_n[5]}]
set_property -dict {PACKAGE_PIN G20 IOSTANDARD LVCMOS12} [get_ports {o_DAC_DIN[5]}]
set_property -dict {PACKAGE_PIN L17 IOSTANDARD LVCMOS12} [get_ports {o_DAC_on_off[5]}]

# DAC 7
set_property -dict {PACKAGE_PIN J16 IOSTANDARD LVCMOS12} [get_ports {o_DAC_SCLK[6]}]
set_property -dict {PACKAGE_PIN J13 IOSTANDARD LVCMOS12} [get_ports {o_DAC_SYNC_n[6]}]
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS12} [get_ports {o_DAC_DIN[6]}]
set_property -dict {PACKAGE_PIN H13 IOSTANDARD LVCMOS12} [get_ports {o_DAC_on_off[6]}]
