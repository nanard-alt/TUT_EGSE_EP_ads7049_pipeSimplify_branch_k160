library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.UT_EGSE_EP_Package.all;

entity EP is
    port(
        -- global
        i_clk_slow                   : in  std_logic;
        i_clk_fast                   : in  std_logic;
        i_reset                      : in  std_logic;
        -- ADC survey
        --i_data_rx_keeped          : in  signed(15 downto 0);
        -- global select spectrum
        i_clk_synchro_spectrum       : in  std_logic;
        i_detector_number            : in  unsigned;
        i_filter_number              : in  std_logic_vector(0 downto 0);
        --input param
        i_gain                       : in  unsigned(31 downto 0);
        i_gain_high_frequency        : in  unsigned(31 downto 0);
        i_TH_ADC                     : in  std_logic_vector(31 downto 0);
        i_TH_rise                    : in  std_logic_vector(31 downto 0);
        i_TH_fall                    : in  std_logic_vector(31 downto 0);
        --input param high frquency
        i_TH_rise_high_frequency     : in  std_logic_vector(31 downto 0);
        i_TH_fall_high_frequency     : in  std_logic_vector(31 downto 0);
        --i_enable_erase            : in  std_logic;
        -- input
        i_ready_CDC                  : in  std_logic;
        i_data_CDC                   : in  signed(15 downto 0);
        -- out
        --o_data_after_gain         : out signed(15 downto 0);
        o_ready_after_gain           : out std_logic;
        --coef
        i_enable_high_filter         : in  std_logic;
        i_coef_fir                   : in  Array_Array_config_32x16_type;
        i_coef_fir_ready             : in  std_logic;
        o_data_before_filter         : out signed(15 downto 0);
        -- out spectrum to fifo pipe out
        o_pipe_out_spectrum_din      : out std_logic_vector(31 downto 0);
        o_pipe_out_spectrum_wr_en    : out std_logic;
        o_spectrum_count_pulse       : out std_logic_vector(31 downto 0);
        --
        o_data_after_energy_level    : out signed(15 downto 0);
        -- out spectrum sd
        o_pipe_out_spectrum_sd_din   : out std_logic_vector(31 downto 0);
        o_pipe_out_spectrum_sd_wr_en : out std_logic;
        o_spectrum_sd_count_pulse    : out std_logic_vector(31 downto 0)
    );
end entity EP;

architecture RTL of EP is

    signal data_before_filter_CDC  : signed(15 downto 0);
    signal ready_before_filter_CDC : std_logic;

    signal ready_before_filter     : std_logic_vector(1 downto 0);
    signal data_before_filter      : Array_config_16signedx2_type;
    signal data_after_filter       : Array_config_16signedx2_type;
    signal Energy_level_max        : Array_config_16signedx2_type;
    signal readyEnergy_level_max   : std_logic_vector(1 downto 0);
    signal data_after_energy_level : Array_config_16signedx2_type;

    signal ready_after_filter : std_logic_vector(1 downto 0);
    signal data_after_gain    : Array_config_16signedx2_type;
    signal ready_after_gain   : std_logic_vector(1 downto 0);

    signal ready_energy_level_max_sd : std_logic_vector(1 downto 0);
    signal energy_level_max_sd       : Array_config_16signedx2_type;

    signal pipe_out_spectrum_din   : Array_config_32stdx2_type;
    signal pipe_out_spectrum_wr_en : std_logic_vector(1 downto 0);
    signal spectrum_count_pulse    : Array_config_32stdx2_type;

    signal pipe_out_spectrum_sd_din   : Array_config_32stdx2_type;
    signal pipe_out_spectrum_sd_wr_en : std_logic_vector(1 downto 0);
    signal spectrum_sd_count_pulse    : Array_config_32stdx2_type;

    signal TH_rise : Array_config_32stdx2_type;
    signal TH_fall : Array_config_32stdx2_type;

    signal gain : Array_config_32unsignedx2_type;

begin

    ------------------------------------------
    --  CDC after Injection or ADC
    ------------------------------------------

    label_generate_complex_clock : if ads_7049_complex_clock = '1' generate
        label_cdc : entity work.Fast_to_Slow_CDC
            port map(
                --global
                i_reset    => i_reset,
                i_clk_fast => i_clk_fast,
                i_clk_slow => i_clk_slow,
                --ready
                i_ready    => i_ready_CDC,
                o_ready    => ready_before_filter_CDC, --ready_slow,
                --data science
                i_data     => i_data_CDC,
                o_data     => data_before_filter_CDC --data_slow
            );
    end generate label_generate_complex_clock;

    ------------------------------------------
    --  Without CDC
    ------------------------------------------

    label_generate : if ads_7049_complex_clock = '0' generate
        data_before_filter_CDC  <= i_data_CDC;
        ready_before_filter_CDC <= i_ready_CDC;
    end generate label_generate;

    data_before_filter(0) <= data_before_filter_CDC;
    data_before_filter(1) <= data_before_filter_CDC;

    ready_before_filter(0) <= ready_before_filter_CDC;
    ready_before_filter(1) <= ready_before_filter_CDC;

    ------------------------------------------
    --  FIR filter
    ------------------------------------------
    generate_label_FIR_filter : for N IN 1 downto 0 generate
        label_FIR_filter : entity work.FIR_filter
            port map(
                --global
                i_clk_slow       => i_clk_slow,
                i_reset          => i_reset,
                --input
                i_coef_fir       => i_coef_fir(N),
                i_coef_fir_ready => i_coef_fir_ready,
                i_data           => data_before_filter(N),
                i_ready          => ready_before_filter(N),
                --out
                o_data           => data_after_filter(N),
                o_ready          => ready_after_filter(N)
            );
    end generate generate_label_FIR_filter;

    o_data_before_filter <= data_before_filter(0) when i_enable_high_filter = '0' else data_before_filter(1);

    --o_data_after_filter  <= data_after_filter;
    --o_ready_after_filter <= ready_after_filter;

    ------------------------------------------
    --  Gain
    ------------------------------------------
    generate_label_gain : for N IN 1 downto 0 generate
        label_gain : entity work.gain
            port map(
                -- global
                i_clk_slow           => i_clk_slow,
                i_reset              => i_reset,
                -- input gain
                i_gain               => gain(N),
                -- input data
                i_data_after_filter  => data_after_filter(N),
                i_ready_after_filter => ready_after_filter(N),
                -- output data
                o_data_after_gain    => data_after_gain(N),
                o_ready_after_gain   => ready_after_gain(N)
            );
    end generate generate_label_gain;

    gain(0) <= i_gain;
    gain(1) <= i_gain_high_frequency;

    --o_data_after_gain  <= data_after_gain;
    o_ready_after_gain <= ready_after_gain(0) when i_enable_high_filter = '0' else ready_after_gain(1);

    ------------------------------------------
    --  Energy level
    ------------------------------------------
    generate_label_energy_level : for N IN 1 downto 0 generate
        label_energy_level : entity work.Energy_level
            port map(
                i_clk_slow                => i_clk_slow,
                i_reset                   => i_reset,
                -- ADC survey
                i_data_before_filter      => data_before_filter(N),
                i_data_after_filter       => data_after_gain(N),
                i_TH_ADC                  => i_TH_ADC,
                i_TH_rise                 => TH_rise(N),
                i_TH_fall                 => TH_fall(N),
                o_Energy_level_max        => Energy_level_max(N),
                o_readyEnergy_level_max   => readyEnergy_level_max(N),
                i_data_after_gain         => data_after_gain(N),
                o_data_after_energy_level => data_after_energy_level(N)
            );
    end generate generate_label_energy_level;

    TH_rise(0) <= i_TH_rise;
    TH_fall(0) <= i_TH_fall;
    TH_rise(1) <= i_TH_rise_high_frequency;
    TH_fall(1) <= i_TH_fall_high_frequency;

    o_data_after_energy_level <= data_after_energy_level(0) when i_enable_high_filter = '0' else data_after_energy_level(1);

    ------------------------------------------
    --  spectrum HD
    ------------------------------------------
    generate_lable_spectrum : for N IN 1 downto 0 generate
        lable_spectrum : entity work.spectrum
            generic map(
                memory_add_size => 10,
                depth_memory    => 1024
            )
            port map(
                -- global
                i_clk_slow                => i_clk_slow,
                i_reset                   => i_reset,
                -- global select spectrum
                i_clk_synchro_spectrum    => i_clk_synchro_spectrum,
                i_detector_number         => i_detector_number,
                i_filter_number           => i_filter_number,
                -- input from detect Energy level
                --i_enable_erase            => i_enable_erase,
                i_Energy_level_max        => Energy_level_max(N),
                i_readyEnergy_level_max   => readyEnergy_level_max(N),
                -- out spectrum to fifo pipe out
                o_pipe_out_spectrum_din   => pipe_out_spectrum_din(N),
                o_pipe_out_spectrum_wr_en => pipe_out_spectrum_wr_en(N),
                o_spectrum_count_pulse    => spectrum_count_pulse(N)
            );
    end generate generate_lable_spectrum;

    o_pipe_out_spectrum_din   <= pipe_out_spectrum_din(0) when i_enable_high_filter = '0' else pipe_out_spectrum_din(1);
    o_pipe_out_spectrum_wr_en <= pipe_out_spectrum_wr_en(0) when i_enable_high_filter = '0' else pipe_out_spectrum_wr_en(1);
    o_spectrum_count_pulse    <= spectrum_count_pulse(0) when i_enable_high_filter = '0' else spectrum_count_pulse(1);

    ------------------------------------------
    --  detect standard energy
    ------------------------------------------
    generate_label_standard_energy : for N IN 1 downto 0 generate
        label_standard_energy : entity work.detect_standard_energy
            port map(
                i_clk_slow                  => i_clk_slow,
                i_reset                     => i_reset,
                i_ready_energy_level_max    => readyEnergy_level_max(N),
                i_energy_level_max          => Energy_level_max(N),
                o_ready_energy_level_max_sd => ready_energy_level_max_sd(N),
                o_energy_level_max_sd       => energy_level_max_sd(N)
            );
    end generate generate_label_standard_energy;

    ------------------------------------------
    --  spectrum Standard definition
    ------------------------------------------
    generate_lable_spectrum_Standard_definition : for N IN 1 downto 0 generate
        lable_spectrum_Standard_definition : entity work.spectrum
            generic map(
                memory_add_size => 3,
                depth_memory    => 8
            )
            port map(
                -- global
                i_clk_slow                => i_clk_slow,
                i_reset                   => i_reset,
                -- global select spectrum
                i_clk_synchro_spectrum    => i_clk_synchro_spectrum,
                i_detector_number         => i_detector_number,
                i_filter_number           => i_filter_number,
                -- input from detect Energy level
                --i_enable_erase            => i_enable_erase,
                i_Energy_level_max        => energy_level_max_sd(N),
                i_readyEnergy_level_max   => ready_energy_level_max_sd(N),
                -- out spectrum to fifo pipe out
                o_pipe_out_spectrum_din   => pipe_out_spectrum_sd_din(N),
                o_pipe_out_spectrum_wr_en => pipe_out_spectrum_sd_wr_en(N),
                o_spectrum_count_pulse    => spectrum_sd_count_pulse(N)
            );
    end generate generate_lable_spectrum_Standard_definition;

    o_pipe_out_spectrum_sd_din   <= pipe_out_spectrum_sd_din(0) when i_enable_high_filter = '0' else pipe_out_spectrum_sd_din(1);
    o_pipe_out_spectrum_sd_wr_en <= pipe_out_spectrum_sd_wr_en(0) when i_enable_high_filter = '0' else pipe_out_spectrum_sd_wr_en(1);
    o_spectrum_sd_count_pulse    <= spectrum_sd_count_pulse(0) when i_enable_high_filter = '0' else spectrum_sd_count_pulse(1);

end architecture RTL;
