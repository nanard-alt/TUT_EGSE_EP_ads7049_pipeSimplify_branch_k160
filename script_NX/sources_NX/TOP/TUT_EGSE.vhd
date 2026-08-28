-- Copyright (C) 2026 Bernard BERTRAND
--
-- This file is part of TUT_EGSE_EP.
--
-- NanoXplore-oriented top level:
-- - Opal Kelly FrontPanel endpoints removed.
-- - Xilinx clock/FIFO IP instances removed.
-- - External logic now drives/reads simple FIFO-like stream ports.
-- - ADS7049 inputs are active and feed the EP processing chain.

library ieee;
library nx;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.UT_EGSE_EP_Package.all;

library nx;
use nx.nxPackage.all;

entity TUT_EGSE is
    port(
        -- Global clock/reset for the NX project.
        i_sys_clk : in std_logic;
        i_reset   : in std_logic; -- reset externe actif bas

        -- interface ADS7049
        o_sck        : out   STD_LOGIC_VECTOR(Detector_Number - 1 downto 0);
        o_cs_n       : out   STD_LOGIC_VECTOR(Detector_Number - 1 downto 0);
        i_sdi        : in    STD_LOGIC_VECTOR(Detector_Number - 1 downto 0);


        -- Former ep00 WireIn content. Bit 0 remains a software reset.
        --i_reg_global : in std_logic_vector(31 downto 0);

        -- External injection stream removed, kept here commented for rollback.
        --o_pipe_in_injection_rd_en : out std_logic;
        --i_pipe_in_injection_empty : in  std_logic;
        --i_pipe_in_injection_valid : in  std_logic;
        --i_pipe_in_injection_dout  : in  std_logic_vector(31 downto 0);

        -- Serialized configuration stream from the OBC emulator.
        i_config_clk   : in std_logic;
        i_config_bit   : in std_logic;
        i_config_wr_en : in std_logic;
        i_config_sof   : in std_logic;

        -- Serialized spectrum streams, replacing Opal Kelly PipeOut FIFOs.
        o_spectrum_bit      : out std_logic;
        o_spectrum_wr_en    : out std_logic;
        o_spectrum_clk      : out std_logic;
        o_spectrum_sof      : out std_logic;
        o_spectrum_sd_bit   : out std_logic;
        o_spectrum_sd_wr_en : out std_logic;
        o_spectrum_sd_clk   : out std_logic;
        o_spectrum_sd_sof   : out std_logic;

        -- DAC121S101 SPI outputs.
        o_DAC_SCLK   : out std_logic_vector(Detector_Number - 1 downto 0);
        o_DAC_SYNC_n : out std_logic_vector(Detector_Number - 1 downto 0);
        o_DAC_DIN    : out std_logic_vector(Detector_Number - 1 downto 0);
        o_DAC_on_off : out std_logic_vector(Detector_Number - 1 downto 0)
    );
end entity TUT_EGSE;

architecture nx of TUT_EGSE is

    signal reset      : std_logic;
    constant C_RESET_CYCLES_MAX : unsigned(15 downto 0) := to_unsigned(1024, 16);
    signal Rst_n   : std_logic;
    signal Rst_cnt : unsigned(15 downto 0);

    signal clk_32Mhz              : std_logic;
    signal clk_synchro_spectrum   : std_logic;
    signal count_clock_1KHz       : unsigned(15 downto 0);
    signal clk_1KHz               : std_logic;
    signal enable_high_filter     : std_logic_vector(Detector_Number - 1 downto 0);
    --signal continuous_injection   : std_logic;

    signal coef_fir                    : Array_Array_config_32x16_type_32x16_type;
    signal coef_fir_ready              : std_logic;
    signal i_coef_fir_ready            : std_logic_vector(Detector_Number - 1 downto 0);
    signal reg_config                  : Array_config_16stdx8_type;
	signal config_control               : std_logic_vector(15 downto 0);
    signal standard_energy_threshold   : Array_Array_Array_config_10x16_type;
    signal i_gain                      : Array_Array_config_16unsignedxDetector_Number_type;

    signal TH_rise                : std_logic_vector(15 downto 0);
    signal TH_fall                : std_logic_vector(15 downto 0);
    signal TH_ADC                 : std_logic_vector(15 downto 0);
    signal TH_rise_high_frequency : std_logic_vector(15 downto 0);
    signal TH_fall_high_frequency : std_logic_vector(15 downto 0);
    signal level_DAC121S          : std_logic_vector(11 downto 0);

    --signal start_capture_config         : std_logic;
    --signal continuous_injection_config  : std_logic;
    signal enable_high_filter_config    : std_logic;
    --signal mode_adc_config              : std_logic;

    --signal data_fast_injection  : signed(11 downto 0);
    --signal ready_fast_injection : std_logic;
    --signal injection_started    : std_logic;

    signal data_rx         : Array_config_12stdxDetector_Number_type;
    signal ready_rx        : std_logic_vector(Detector_Number - 1 downto 0);
    signal data_rx_keeped  : Array_config_16stdxDetector_Number_type;
    signal ready_rx_keeped : std_logic_vector(Detector_Number - 1 downto 0);
    signal i_data_CDC      : Array_config_16signedxDetector_Number_type;
    signal i_ready_CDC     : std_logic_vector(Detector_Number - 1 downto 0);

    signal o_pipe_out_spectrum_din    : Array_config_32stdxDetector_Number_type;
    signal o_pipe_out_spectrum_wr_en  : std_logic_vector(Detector_Number - 1 downto 0);
    signal pipe_out_spectrum_din_mux   : std_logic_vector(31 downto 0);
    signal pipe_out_spectrum_wr_en_mux : std_logic;
    signal o_pipe_out_spectrum_sd_din    : Array_config_32stdxDetector_Number_type;
    signal o_pipe_out_spectrum_sd_wr_en  : std_logic_vector(Detector_Number - 1 downto 0);
    signal pipe_out_spectrum_sd_din_mux   : std_logic_vector(31 downto 0);
    signal pipe_out_spectrum_sd_wr_en_mux : std_logic;

    --signal i_Start_Capture              : STD_LOGIC_VECTOR(Detector_Number - 1 downto 0);

    signal fifo_spectrum_dout  : std_logic_vector(31 downto 0);
    signal fifo_spectrum_empty : std_logic;
    signal fifo_spectrum_rd_en : std_logic;

    signal fifo_spectrum_sd_dout  : std_logic_vector(31 downto 0);
    signal fifo_spectrum_sd_empty : std_logic;
    signal fifo_spectrum_sd_rd_en : std_logic;

    signal config_word                    : std_logic_vector(31 downto 0);
    signal config_word_valid              : std_logic;
    signal config_fifo_full               : std_logic;
    signal pipe_in_config_rd_en           : std_logic;
    signal pipe_in_config_empty           : std_logic;
    signal pipe_in_config_valid           : std_logic;
    signal pipe_in_config_dout            : std_logic_vector(31 downto 0);
    signal pipe_in_config_data_count      : std_logic_vector(9 downto 0);
begin

    clk_32Mhz <= i_sys_clk;


    ---------------------------------------------------------------------------------------------------------------------------------
    --
    -- Reset generation, negative polarity, fixed time delay to ensure VDD3V3 stability
    --
    ---------------------------------------------------------------------------------------------------------------------------------

    -- Synchronize general reset on the slower clock
    p_Reset_Generator : process(i_reset, i_sys_clk)
    begin
        if i_reset = '0' then
            Rst_n   <= '0';
            Rst_cnt <= (others => '0');
        elsif rising_edge(i_sys_clk) then
            if Rst_cnt < C_RESET_CYCLES_MAX then
                Rst_n   <= '0';
                Rst_cnt <= Rst_cnt + 1;
            else
                Rst_n <= '1';
            end if;
        end if;
    end process p_Reset_Generator;

    ---------------------------------------------------------------------------------------------------------------------------------
    --
    -- NX-BD IpCore (NG-MEDIUM)
    --
    ---------------------------------------------------------------------------------------------------------------------------------
    -- The NX Buffer Driver circuit forces internally generated reset signal to be reinjected in low skew routing network

/*     inst_NX_BD_Rst_n : NX_BD
        generic map(
            mode => "global_lowskew"
        )
        port map(
            I => Rst_n,
            O => reset
        ); */

	reset <= Rst_n;

    i_coef_fir_ready <= (others => coef_fir_ready);

	config_control <= reg_config(0);
	
    --start_capture_config        <= config_control(0);
    --continuous_injection_config <= config_control(1);
	enable_high_filter_config   <= config_control(2);
    --mode_adc_config             <= config_control(3);
	
    TH_rise                <= reg_config(2);
    TH_fall                <= reg_config(3);
    TH_ADC                 <= reg_config(4);
    level_DAC121S          <= reg_config(5)(11 downto 0);
    TH_rise_high_frequency <= reg_config(6);
    TH_fall_high_frequency <= reg_config(7);

    --i_Start_Capture    <= (others => start_capture_config); remove raw data is not use
    enable_high_filter <= (others => enable_high_filter_config);
    --continuous_injection <= continuous_injection_config;

    --------------------------------------------------------------------------
    -- Spectrum cycle and DAC clocking
    --------------------------------------------------------------------------

    label_cycle_spectrum : entity work.cycle_spectrum
        port map(
            sys_clk                => i_sys_clk,
            reset                  => reset,
            o_clk_synchro_spectrum => clk_synchro_spectrum
        );

    label_clock_1KHz : process(i_sys_clk, reset) is
    begin
        if reset = '0' then
            count_clock_1KHz <= (others => '0');
            clk_1KHz         <= '0';
        elsif rising_edge(i_sys_clk) then
            count_clock_1KHz <= count_clock_1KHz + 1;
            if to_integer(count_clock_1KHz) >= 10000 then
                clk_1KHz         <= not clk_1KHz;
                count_clock_1KHz <= (others => '0');
            end if;
        end if;
    end process;

    ------------------------------------------
    --  Injection removed, kept commented for rollback
    ------------------------------------------  

    --label_Injection : entity work.Injection
    --    port map(
    --        -- global
    --        reset                  => reset,
    --        i_clk_fast             => clk_32Mhz,
    --        -- commande injection
    --        i_continuous_injection => continuous_injection,
    --        -- entree FIFO PipeIn injection
    --        o_pipe_in_rd_en        => o_pipe_in_injection_rd_en,
    --        i_pipe_in_empty        => i_pipe_in_injection_empty,
    --        i_pipe_in_valid        => i_pipe_in_injection_valid,
    --        i_pipe_in_dout         => signed(i_pipe_in_injection_dout(11 downto 0)),
    --        -- sortie injection remplacant l'ADC
    --        o_injection_started    => injection_started,
    --        o_data                 => data_fast_injection,
    --        o_ready                => ready_fast_injection
    --    );

    ------------------------------------------
    -- ADS7049 receivers
    ------------------------------------------

    generate_label_Rx_fe_ads7049_and : for N in 0 to Detector_Number - 1 generate
        label_read_ADC : entity work.Rx_fe_ads7049_and
            port map(
                clk        => clk_32Mhz,
                rst        => reset,
                o_sck      => o_sck(N),
                o_cs_n     => o_cs_n(N),
                i_sdi      => i_sdi(N),
                o_data_rx  => data_rx(N),
                o_ready_rx => ready_rx(N)
            );
    end generate generate_label_Rx_fe_ads7049_and;

    ------------------------------------------
    -- Capture ADC data on the rising edge before the CDC input
    ------------------------------------------

    generate_label_keep_data_from_ADC : for N in 0 to Detector_Number - 1 generate
        label_keep_data_from_ADC : process(clk_32Mhz, reset) is
        begin
            if reset = '0' then
                data_rx_keeped(N)  <= (others => '0');
                ready_rx_keeped(N) <= '0';
            elsif rising_edge(clk_32Mhz) then
                ready_rx_keeped(N) <= '0';
                if ready_rx(N) = '1' then
                    ready_rx_keeped(N) <= '1';
                    data_rx_keeped(N)  <= '0' & data_rx(N) & b"000";
                end if;
            end if;
        end process;

    end generate generate_label_keep_data_from_ADC;

    ------------------------------------------
    --  ADC science data path
    ------------------------------------------  
    generate_label_science_data : for N in 0 to Detector_Number - 1 generate
        label_science_data : i_data_CDC(N) <= signed(data_rx_keeped(N));
        --label_mux_science_data : i_data_CDC(N) <= signed(data_rx_keeped(N)) when mode_adc_config = '1' else ('0' & data_fast_injection & b"000");
    end generate generate_label_science_data;

    generate_label_science_ready : for N in 0 to Detector_Number - 1 generate
        label_science_ready : i_ready_CDC(N) <= ready_rx_keeped(N);
        --label_mux_science_ready : i_ready_CDC(N) <= ready_rx_keeped(N) when mode_adc_config = '1' else ready_fast_injection;
    end generate generate_label_science_ready;


    --------------------------------------------------------------------------
    -- Energy processing, one EP instance per detector.
    --------------------------------------------------------------------------

    generate_EP : for N in 0 to Detector_Number - 1 generate
        label_Ep : entity work.EP
            port map(
                i_clk_slow                   => i_sys_clk,
                i_clk_fast                   => clk_32Mhz,
                i_reset                      => reset,
                i_clk_synchro_spectrum       => clk_synchro_spectrum,
                i_detector_number            => to_unsigned(N, Detector_Number_Width),
                i_gain                       => i_gain(N),
                i_TH_ADC                     => TH_ADC,
                i_TH_rise                    => TH_rise,
                i_TH_fall                    => TH_fall,
                i_TH_rise_high_frequency     => TH_rise_high_frequency,
                i_TH_fall_high_frequency     => TH_fall_high_frequency,
                i_ready_CDC                  => i_ready_CDC(N),
                i_data_CDC                   => i_data_CDC(N),
                i_enable_high_filter         => enable_high_filter(N),
                i_coef_fir                   => coef_fir(N),
                i_coef_fir_ready             => i_coef_fir_ready(N),
                i_standard_energy_threshold  => standard_energy_threshold(N),
                o_data_before_filter         => open,
                o_ready_after_gain           => open,
                o_data_after_energy_level    => open,
                o_pipe_out_spectrum_din      => o_pipe_out_spectrum_din(N),
                o_pipe_out_spectrum_wr_en    => o_pipe_out_spectrum_wr_en(N),
                o_pipe_out_spectrum_sd_din   => o_pipe_out_spectrum_sd_din(N),
                o_pipe_out_spectrum_sd_wr_en => o_pipe_out_spectrum_sd_wr_en(N)
            );
    end generate generate_EP;

    --------------------------------------------------------------------------
    -- Mux detector spectrum streams into one HD stream and one SD stream.
    --------------------------------------------------------------------------

    lebel_process_mux_data_spectrum_packet : process(i_sys_clk, reset) is
    begin
        if reset = '0' then
            pipe_out_spectrum_wr_en_mux <= '0';
            pipe_out_spectrum_din_mux   <= (others => '0');
        elsif rising_edge(i_sys_clk) then
            pipe_out_spectrum_wr_en_mux <= '0';
            pipe_out_spectrum_din_mux   <= (others => '0');

            for i in 0 to Detector_Number - 1 loop
                if o_pipe_out_spectrum_wr_en(i) = '1' then
                    pipe_out_spectrum_din_mux   <= o_pipe_out_spectrum_din(i);
                    pipe_out_spectrum_wr_en_mux <= '1';
                end if;
            end loop;
        end if;
    end process lebel_process_mux_data_spectrum_packet;

    lebel_process_mux_data_spectrum_packet_SD : process(i_sys_clk, reset) is
    begin
        if reset = '0' then
            pipe_out_spectrum_sd_wr_en_mux <= '0';
            pipe_out_spectrum_sd_din_mux   <= (others => '0');
        elsif rising_edge(i_sys_clk) then
            pipe_out_spectrum_sd_wr_en_mux <= '0';
            pipe_out_spectrum_sd_din_mux   <= (others => '0');

            for i in 0 to Detector_Number - 1 loop
                if o_pipe_out_spectrum_sd_wr_en(i) = '1' then
                    pipe_out_spectrum_sd_din_mux   <= o_pipe_out_spectrum_sd_din(i);
                    pipe_out_spectrum_sd_wr_en_mux <= '1';
                end if;
            end loop;
        end if;
    end process lebel_process_mux_data_spectrum_packet_SD;

    label_fifo_spectrum : entity work.fifo_sync
        generic map(
            DATA_WIDTH => 32,
            DEPTH      => 8192,
            ADDR_WIDTH => 13
        )
        port map(
            i_clk   => i_sys_clk,
            i_reset => reset,
            i_wr_en => pipe_out_spectrum_wr_en_mux,
            i_din   => pipe_out_spectrum_din_mux,
            o_full  => open,
            i_rd_en => fifo_spectrum_rd_en,
            o_dout  => fifo_spectrum_dout,
            o_empty => fifo_spectrum_empty
        );

    label_fifo_spectrum_sd : entity work.fifo_sync
        generic map(
            DATA_WIDTH => 32,
            DEPTH      => 128,
            ADDR_WIDTH => 7
        )
        port map(
            i_clk   => i_sys_clk,
            i_reset => reset,
            i_wr_en => pipe_out_spectrum_sd_wr_en_mux,
            i_din   => pipe_out_spectrum_sd_din_mux,
            o_full  => open,
            i_rd_en => fifo_spectrum_sd_rd_en,
            o_dout  => fifo_spectrum_sd_dout,
            o_empty => fifo_spectrum_sd_empty
        );

    label_spectrum_serializer : entity work.spectrum_serializer
        port map(
            i_clk               => i_sys_clk,
            i_reset             => reset,
            i_spectrum_dout     => fifo_spectrum_dout,
            i_spectrum_empty    => fifo_spectrum_empty,
            o_spectrum_rd_en    => fifo_spectrum_rd_en,
            i_spectrum_sd_dout  => fifo_spectrum_sd_dout,
            i_spectrum_sd_empty => fifo_spectrum_sd_empty,
            o_spectrum_sd_rd_en => fifo_spectrum_sd_rd_en,
            o_spectrum_bit      => o_spectrum_bit,
            o_spectrum_wr_en    => o_spectrum_wr_en,
            o_spectrum_clk      => o_spectrum_clk,
            o_spectrum_sof      => o_spectrum_sof,
            o_spectrum_sd_bit   => o_spectrum_sd_bit,
            o_spectrum_sd_wr_en => o_spectrum_sd_wr_en,
            o_spectrum_sd_clk   => o_spectrum_sd_clk,
            o_spectrum_sd_sof   => o_spectrum_sd_sof
        );

    --------------------------------------------------------------------------
    -- Configuration serial input path.
    --------------------------------------------------------------------------

    label_config_unserializer : entity work.config_unserializer
        port map(
            i_clk        => i_config_clk,
            i_reset      => reset,
            i_serial_bit => i_config_bit,
            i_wr_en      => i_config_wr_en,
            i_sof        => i_config_sof,
            o_word       => config_word,
            o_word_valid => config_word_valid
        );

    label_fifo_config : entity work.config_fifo
        generic map(
            DATA_WIDTH => 32,
            DEPTH      => 1024,
            ADDR_WIDTH => 10
        )
        port map(
            i_wr_clk        => i_config_clk,
            i_rd_clk        => i_sys_clk,
            i_reset         => reset,
            i_wr_en         => config_word_valid,
            i_din           => config_word,
            o_full          => config_fifo_full,
            i_rd_en         => pipe_in_config_rd_en,
            o_dout          => pipe_in_config_dout,
            o_empty         => pipe_in_config_empty,
            o_valid         => pipe_in_config_valid,
            o_rd_data_count => pipe_in_config_data_count
        );

    --------------------------------------------------------------------------
    -- DAC outputs.
    --------------------------------------------------------------------------

    generate_label_Top_DAC121S101_Driver : for N in 0 to Detector_Number - 1 generate
        label_Top_DAC121S101_Driver : entity work.Top_DAC121S101_Driver
            port map(
                i_reset         => reset,
                i_clk           => clk_1KHz,
                i_level_DAC121S => level_DAC121S,
                o_DAC_SCLK      => o_DAC_SCLK(N),
                o_DAC_SYNC_n    => o_DAC_SYNC_n(N),
                o_DAC_DIN       => o_DAC_DIN(N),
                o_DAC_on_off    => o_DAC_on_off(N)
            );
    end generate generate_label_Top_DAC121S101_Driver;

    --------------------------------------------------------------------------
    -- Configuration stream reader.
    --------------------------------------------------------------------------

    label_FSM_pipe_in_config : entity work.FSM_read_config
        port map(
            i_clk_slow                  => i_sys_clk,
            i_reset                     => reset,
            i_pipe_in_config_empty      => pipe_in_config_empty,
            i_pipe_in_config_valid      => pipe_in_config_valid,
            i_pipe_in_config_dout       => signed(pipe_in_config_dout),
            i_pipe_in_rd_data_count     => pipe_in_config_data_count,
            o_pipe_in_config_rd_en      => pipe_in_config_rd_en,
            o_coef_fir_ready            => coef_fir_ready,
            o_coef_fir_buf              => coef_fir,
            o_reg_config                => reg_config,
            o_standard_energy_threshold => standard_energy_threshold,
            o_gain                      => i_gain
        );

--    i_coef_fir_ready <= (others => coef_fir_ready);

--    TH_rise                <= reg_config(2);
--    TH_fall                <= reg_config(3);
--    TH_ADC                 <= reg_config(4);
--    level_DAC121S          <= reg_config(5)(11 downto 0);
--    TH_rise_high_frequency <= reg_config(6);
--    TH_fall_high_frequency <= reg_config(7);

end architecture nx;
