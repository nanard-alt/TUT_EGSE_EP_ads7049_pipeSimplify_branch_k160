"""Ultra300 BGA484 IO constraints for TUT_EGSE.
Generated from the validated top-signal pin map in constraint/ULTRA300_BGA484_TUT_EGSE_top_signals.xlsx.
"""


def add_banks_bga484(project):
    banks = {
        'IOB12': {"voltage": "3.3V"},
        'IOB13': {"voltage": "3.3V"},
        'IOB14': {"voltage": "3.3V"},
        'IOB7' : {"voltage": "3.3V"},
        'IOB8' : {"voltage": "3.3V"},
        'IOB15': {"voltage": "1.8V"},
    }
    project.addBanks(banks)


def add_pads_bga484(project):
    pads = {
        'i_sys_clk'               : {"location": 'IOB15_D09P_CLK'  , "standard": "LVCMOS", "drive": '4mA', "differential": False, "turbo": True},  # BGA A11, Clock
        'i_config_clk'            : {"location": 'IOB08_D13'       , "standard": "LVCMOS", "drive": '4mA', "differential": False, "turbo": True},  # BGA P19, Config island
        'o_sck[0]'                : {"location": 'IOB14_D22'       , "standard": "LVCMOS", "drive": '8mA', "differential": False, "turbo": True},  # BGA A2, ADC
        'o_cs_n[0]'               : {"location": 'IOB14_D19'       , "standard": "LVCMOS", "drive": '8mA', "differential": False},  # BGA B2, ADC
        'i_sdi[0]'                : {"location": 'IOB14_D15'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA C2, ADC
        'o_sck[1]'                : {"location": 'IOB14_D17'       , "standard": "LVCMOS", "drive": '8mA', "differential": False, "turbo": True},  # BGA D1, ADC
        'o_cs_n[1]'               : {"location": 'IOB14_D13'       , "standard": "LVCMOS", "drive": '8mA', "differential": False},  # BGA D2, ADC
        'i_sdi[1]'                : {"location": 'IOB14_D21'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA E1, ADC
        'o_sck[2]'                : {"location": 'IOB14_D11'       , "standard": "LVCMOS", "drive": '8mA', "differential": False, "turbo": True},  # BGA E2, ADC
        'o_cs_n[2]'               : {"location": 'IOB14_D14'       , "standard": "LVCMOS", "drive": '8mA', "differential": False},  # BGA F1, ADC
        'i_sdi[2]'                : {"location": 'IOB14_D18'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA F2, ADC
        'o_sck[3]'                : {"location": 'IOB14_D23'       , "standard": "LVCMOS", "drive": '8mA', "differential": False, "turbo": True},  # BGA G1, ADC
        'o_cs_n[3]'               : {"location": 'IOB14_D03'       , "standard": "LVCMOS", "drive": '8mA', "differential": False},  # BGA G2, ADC
        'i_sdi[3]'                : {"location": 'IOB14_D05'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA H1, ADC
        'o_sck[4]'                : {"location": 'IOB12_D23'       , "standard": "LVCMOS", "drive": '8mA', "differential": False, "turbo": True},  # BGA P2, ADC
        'o_cs_n[4]'               : {"location": 'IOB12_D19'       , "standard": "LVCMOS", "drive": '8mA', "differential": False},  # BGA R2, ADC
        'i_sdi[4]'                : {"location": 'IOB12_D09'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA T1, ADC
        'o_sck[5]'                : {"location": 'IOB12_D10'       , "standard": "LVCMOS", "drive": '8mA', "differential": False, "turbo": True},  # BGA T2, ADC
        'o_cs_n[5]'               : {"location": 'IOB12_D08'       , "standard": "LVCMOS", "drive": '8mA', "differential": False},  # BGA U1, ADC
        'i_sdi[5]'                : {"location": 'IOB12_D11'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA U2, ADC
        'o_sck[6]'                : {"location": 'IOB12_D07'       , "standard": "LVCMOS", "drive": '8mA', "differential": False, "turbo": True},  # BGA V1, ADC
        'o_cs_n[6]'               : {"location": 'IOB12_D12'       , "standard": "LVCMOS", "drive": '8mA', "differential": False},  # BGA V2, ADC
        'i_sdi[6]'                : {"location": 'IOB12_D06'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA W1, ADC
        'o_DAC_SCLK[0]'           : {"location": 'IOB14_D20'       , "standard": "LVCMOS", "drive": '4mA', "differential": False, "turbo": True},  # BGA A3, DAC
        'o_DAC_SYNC_n[0]'         : {"location": 'IOB14_D16'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA B3, DAC
        'o_DAC_DIN[0]'            : {"location": 'IOB14_D12'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA B4, DAC
        'o_DAC_on_off[0]'         : {"location": 'IOB14_D10'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA C3, DAC
        'o_DAC_SCLK[1]'           : {"location": 'IOB14_D07'       , "standard": "LVCMOS", "drive": '4mA', "differential": False, "turbo": True},  # BGA C4, DAC
        'o_DAC_SYNC_n[1]'         : {"location": 'IOB14_D08'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA D3, DAC
        'o_DAC_DIN[1]'            : {"location": 'IOB14_D09'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA E3, DAC
        'o_DAC_on_off[1]'         : {"location": 'IOB14_D01'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA F3, DAC
        'o_DAC_SCLK[2]'           : {"location": 'IOB12_D22'       , "standard": "LVCMOS", "drive": '4mA', "differential": False, "turbo": True},  # BGA P3, DAC
        'o_DAC_SYNC_n[2]'         : {"location": 'IOB12_D21'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA P4, DAC
        'o_DAC_DIN[2]'            : {"location": 'IOB12_D20'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA R3, DAC
        'o_DAC_on_off[2]'         : {"location": 'IOB12_D18'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA T3, DAC
        'o_DAC_SCLK[3]'           : {"location": 'IOB12_D17'       , "standard": "LVCMOS", "drive": '4mA', "differential": False, "turbo": True},  # BGA T4, DAC
        'o_DAC_SYNC_n[3]'         : {"location": 'IOB12_D15'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA U3, DAC
        'o_DAC_DIN[3]'            : {"location": 'IOB12_D16'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA U4, DAC
        'o_DAC_on_off[3]'         : {"location": 'IOB12_D13'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA V3, DAC
        'o_DAC_SCLK[4]'           : {"location": 'IOB13_D12'       , "standard": "LVCMOS", "drive": '4mA', "differential": False, "turbo": True},  # BGA K3, DAC
        'o_DAC_SYNC_n[4]'         : {"location": 'IOB13_D11'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA L3, DAC
        'o_DAC_DIN[4]'            : {"location": 'IOB13_D13'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA L4, DAC
        'o_DAC_on_off[4]'         : {"location": 'IOB13_D03'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA M3, DAC
        'o_DAC_SCLK[5]'           : {"location": 'IOB14_D00'       , "standard": "LVCMOS", "drive": '4mA', "differential": False, "turbo": True},  # BGA F4, DAC
        'o_DAC_SYNC_n[5]'         : {"location": 'IOB14_D04'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA G3, DAC
        'o_DAC_DIN[5]'            : {"location": 'IOB14_D02'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA H3, DAC
        'o_DAC_on_off[5]'         : {"location": 'IOB13_D14'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA M4, DAC
        'o_DAC_SCLK[6]'           : {"location": 'IOB13_D09'       , "standard": "LVCMOS", "drive": '4mA', "differential": False, "turbo": True},  # BGA N3, DAC
        'o_DAC_SYNC_n[6]'         : {"location": 'IOB13_D15'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA N4, DAC
        'o_DAC_DIN[6]'            : {"location": 'IOB12_D14'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA V4, DAC
        'o_DAC_on_off[6]'         : {"location": 'IOB12_D03'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA W3, DAC
        'o_spectrum_bit'          : {"location": 'IOB07_D02'       , "standard": "LVCMOS", "drive": '4mA', "differential": False, "turbo": True},  # BGA Y19, Spectrum HD island
        'o_spectrum_wr_en'        : {"location": 'IOB07_D05'       , "standard": "LVCMOS", "drive": '4mA', "differential": False, "turbo": True},  # BGA Y20, Spectrum HD island
        'o_spectrum_clk'          : {"location": 'IOB07_D17'       , "standard": "LVCMOS", "drive": '4mA', "differential": False, "turbo": True},  # BGA Y21, Spectrum HD island
        'o_spectrum_sof'          : {"location": 'IOB07_D19'       , "standard": "LVCMOS", "drive": '4mA', "differential": False, "turbo": True},  # BGA Y22, Spectrum HD island
        'o_spectrum_sd_bit'       : {"location": 'IOB08_D09'       , "standard": "LVCMOS", "drive": '4mA', "differential": False, "turbo": True},  # BGA L21, Spectrum SD island
        'o_spectrum_sd_wr_en'     : {"location": 'IOB08_D00'       , "standard": "LVCMOS", "drive": '4mA', "differential": False, "turbo": True},  # BGA L22, Spectrum SD island
        'o_spectrum_sd_clk'       : {"location": 'IOB08_D08'       , "standard": "LVCMOS", "drive": '4mA', "differential": False, "turbo": True},  # BGA M21, Spectrum SD island
        'o_spectrum_sd_sof'       : {"location": 'IOB08_D01'       , "standard": "LVCMOS", "drive": '4mA', "differential": False, "turbo": True},  # BGA M22, Spectrum SD island
        'i_config_bit'            : {"location": 'IOB08_D11'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA P20, Config island
        'i_config_wr_en'          : {"location": 'IOB08_D06'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA P21, Config island
        'i_config_sof'            : {"location": 'IOB08_D03'       , "standard": "LVCMOS", "drive": '4mA', "differential": False},  # BGA P22, Config island
    }
    project.addPads(pads)


def add_io_constraints_bga484(project):
    add_banks_bga484(project)
    add_pads_bga484(project)
