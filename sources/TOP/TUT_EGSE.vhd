-- Copyright (C) 2026 Bernard BERTRAND
--
-- This file is part of TUT_EGSE_EP.
--
-- This software is governed by the CeCILL license under French law
-- and abiding by the rules of distribution of free software.
-- You can use, modify and/or redistribute the software under the terms
-- of the CeCILL license as circulated by CEA, CNRS and Inria at:
-- http://www.cecill.info
--
-- See LICENSE.txt for the full license text.

--------------------------------------------------------------------------
-- Counters.vhd
--
-- HDL for the counters sample.  This HDL describes two counters operating
-- on different board clocks and with slightly different functionality.
-- The counter controls and counter values are connected to endpoints so
-- that FrontPanel may control and observe them.
--
-- Copyright (c) 2005-2009  Opal Kelly Incorporated
-- $Rev$ $Date$
--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

use IEEE.std_logic_misc.all;
use ieee.numeric_std.all;
use work.FRONTPANEL.all;

use work.UT_EGSE_EP_Package.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity TUT_EGSE is
    port(
        okUH         : in    STD_LOGIC_VECTOR(4 downto 0);
        okHU         : out   STD_LOGIC_VECTOR(2 downto 0);
        okUHU        : inout STD_LOGIC_VECTOR(31 downto 0);
        okAA         : inout STD_LOGIC; --removed for simulation
        -- clock OK
        sys_clkp     : in    STD_LOGIC;
        sys_clkn     : in    STD_LOGIC;
        -- ADS7049
        -- ADC comment: ADC IO disabled/commented out.
        -- o_sck        : out   STD_LOGIC_VECTOR(Detector_Number - 1 downto 0);
        -- o_cs_n       : out   STD_LOGIC_VECTOR(Detector_Number - 1 downto 0);
        -- i_sdi        : in    STD_LOGIC_VECTOR(Detector_Number - 1 downto 0);
        led          : out   STD_LOGIC_VECTOR(3 downto 0);
        -- DAC121S
        o_DAC_SCLK   : out   STD_LOGIC_VECTOR(Detector_Number - 1 downto 0);
        o_DAC_SYNC_n : out   STD_LOGIC_VECTOR(Detector_Number - 1 downto 0);
        o_DAC_DIN    : out   STD_LOGIC_VECTOR(Detector_Number - 1 downto 0);
        o_DAC_on_off : out   STD_LOGIC_VECTOR(Detector_Number - 1 downto 0)
    );
end TUT_EGSE;

architecture arch of TUT_EGSE is

    signal sys_clk : STD_LOGIC;

    signal okClk : STD_LOGIC;
    signal okHE  : STD_LOGIC_VECTOR(112 downto 0);
    signal okEH  : STD_LOGIC_VECTOR(64 downto 0);
    signal okEHx : STD_LOGIC_VECTOR(65 * 24 - 1 downto 0);

    signal reg_global                  : STD_LOGIC_VECTOR(31 downto 0);
    signal fifo_count_raw_data         : Array_config_32stdxDetector_Number_type;
    signal fifo_data_count_spectrum    : STD_LOGIC_VECTOR(31 downto 0);
    signal reg_spectrum_count_pulse    : Array_config_32stdxDetector_Number_type;
    signal fifo_data_count_spectrum_sd : STD_LOGIC_VECTOR(31 downto 0);
    signal reg_spectrum_sd_count_pulse : Array_config_32stdxDetector_Number_type;

    signal reset : std_logic;
    signal count : unsigned(31 downto 0);

    signal clk_synchro_spectrum  : std_logic;
    signal enable_cycle_spectrum : STD_LOGIC_VECTOR(1 downto 0);
    --signal clk_synchro_spectrum   : std_logic;

    -- pipe in

    signal pipe_in_injection_din_fifo   : STD_LOGIC_VECTOR(31 downto 0);
    signal pipe_in_injection_wr_en_fifo : STD_LOGIC;
    signal pipe_in_injection_rd_en_fifo : STD_LOGIC;

    signal pipe_in_injection_dout_fifo  : STD_LOGIC_VECTOR(31 downto 0);
    signal pipe_in_injection_empty_fifo : STD_LOGIC;
    signal pipe_in_injection_valid_fifo : STD_LOGIC;

    signal dout_fifo_pipe_out_raw_data  : Array_config_32stdxDetector_Number_type;
    signal rd_en_fifo_pipe_out_raw_data : STD_LOGIC_VECTOR(Detector_Number - 1 downto 0);
    signal led_buf                      : STD_LOGIC_VECTOR(3 downto 0);

    signal ep01wire : STD_LOGIC_VECTOR(31 downto 0);

    signal pipe_in_config_din   : STD_LOGIC_VECTOR(31 downto 0);
    signal pipe_in_config_wr_en : std_logic;
    signal pipe_in_config_rd_en : std_logic;
    signal pipe_in_config_dout  : STD_LOGIC_VECTOR(31 downto 0);

    signal pipe_in_config_empty : std_logic;
    signal pipe_in_config_valid : std_logic;

    signal reset_wire                 : std_logic;
    signal locked                     : std_logic;
    signal din_fifo_pipe_out_raw_data : Array_config_32signedxDetector_Number_type;

    signal clk_32Mhz : STD_LOGIC;

    signal data_before_filter : Array_config_16signedxDetector_Number_type;

    signal ready_after_gain             : STD_LOGIC_VECTOR(Detector_Number - 1 downto 0);
    signal wr_en_fifo_pipe_out_raw_data : STD_LOGIC_VECTOR(Detector_Number - 1 downto 0);
    signal empty_raw_data               : std_logic;
    signal i_Start_Capture              : STD_LOGIC_VECTOR(Detector_Number - 1 downto 0);
    signal i_level_trigger              : STD_LOGIC_VECTOR(Detector_Number - 1 downto 0);

    signal pipe_in_confi_rd_data_count : std_logic_vector(9 downto 0);
    signal coef_fir                    : Array_Array_config_32x16_type_32x16_type;
    signal i_coef_fir_ready            : STD_LOGIC_VECTOR(Detector_Number - 1 downto 0);

    signal coef_fir_ready : std_logic;

    signal rd_fifo_pipe_out_data_count_raw_data : Array_config_11stdxDetector_Number_type;

    signal ready_fast_injection : std_logic;
    signal data_fast_injection  : signed(11 downto 0);

    signal data_rx         : Array_config_12stdxDetector_Number_type;
    signal ready_rx        : std_logic_vector(Detector_Number - 1 downto 0);
    signal i_data_CDC      : Array_config_16signedxDetector_Number_type;
    signal i_ready_CDC     : std_logic_vector(Detector_Number - 1 downto 0);
    signal data_rx_keeped  : Array_config_16stdxDetector_Number_type;
    signal ready_rx_keeped : std_logic_vector(Detector_Number - 1 downto 0);

    signal TH_rise : std_logic_vector(31 downto 0);
    signal TH_fall : std_logic_vector(31 downto 0);
    signal TH_ADC  : std_logic_vector(31 downto 0);

    signal TH_rise_high_frequency : std_logic_vector(31 downto 0);
    signal TH_fall_high_frequency : std_logic_vector(31 downto 0);

    signal pipe_out_spectrum_rd_en : std_logic;
    signal pipe_out_spectrum_dout  : std_logic_vector(31 downto 0);

    signal pipe_out_spectrum_sd_rd_en : std_logic;
    signal pipe_out_spectrum_sd_dout  : std_logic_vector(31 downto 0);

    signal pipe_out_spectrum_din      : std_logic_vector(31 downto 0);
    signal o_pipe_out_spectrum_din    : Array_config_32stdxDetector_Number_type;
    signal o_pipe_out_spectrum_sd_din : Array_config_32stdxDetector_Number_type;
    signal pipe_out_spectrum_sd_din   : std_logic_vector(31 downto 0);

    signal pipe_out_spectrum_wr_en            : std_logic;
    signal o_pipe_out_spectrum_wr_en          : STD_LOGIC_VECTOR(Detector_Number - 1 downto 0);
    signal o_pipe_out_spectrum_sd_wr_en       : STD_LOGIC_VECTOR(Detector_Number - 1 downto 0);
    signal pipe_out_spectrum_sd_wr_en         : std_logic;
    signal pipe_out_rd_data_count_spectrum    : STD_LOGIC_VECTOR(13 downto 0);
    signal pipe_out_rd_data_count_spectrum_sd : STD_LOGIC_VECTOR(12 downto 0);

    signal pipe_out_spectrum_wr_en_fifo : std_logic;
    signal pipe_out_spectrum_din_fifo   : std_logic_vector(31 downto 0);
    signal spectrum_count_pulse         : Array_config_32stdxDetector_Number_type;
    signal spectrum_sd_count_pulse      : Array_config_32stdxDetector_Number_type;

    signal pipe_out_spectrum_sd_wr_en_fifo : std_logic;
    signal pipe_out_spectrum_sd_din_fifo   : std_logic_vector(31 downto 0);

    signal empty_fifo_pipe_out_raw_data : STD_LOGIC_VECTOR(Detector_Number - 1 downto 0);
    signal din_fifo_raw_data            : Array_config_32signedxDetector_Number_type;
    signal injection_started            : std_logic;
    signal continuous_injection         : std_logic;
    signal enable_high_filter           : STD_LOGIC_VECTOR(Detector_Number - 1 downto 0);
    signal i_gain                       : Array_Array_config_32stdxDetector_Number_type;
    --signal i_gain_high_frequency        : Array_config_32stdxDetector_Number_type;
    --signal gain                         : Array_Array_config_32stdxDetector_Number_type;
    --signal gain_high_frequency          : Array_config_32stdx2_type;
    signal reg_config                   : Array_config_32stdx8_type;
    --signal data_after_gain              : Array_config_16signedx2_type;
    signal data_after_energy_level      : Array_config_16signedxDetector_Number_type;

    --signal Start            : std_logic;
    --signal Num_Data         : std_logic_vector(11 downto 0);
    signal level_DAC121S    : std_logic_vector(31 downto 0);
    --signal Busy             : std_logic;
    signal count_clock_1KHz : unsigned(15 downto 0);
    signal clk_1KHz         : std_logic;

    signal cmpt_sequencer    : unsigned(14 downto 0);
    signal enable_clock_1KHz : std_logic;
    --signal TH_ADC_wire       : std_logic_vector(31 downto 0);

    --signal ep23wire : std_logic_vector(31 downto 0);
    --signal ep24wire : std_logic_vector(31 downto 0);
    --signal ep25wire : std_logic_vector(31 downto 0);

begin

    --led(7)   <= '0' when (led_buf(7) = '1') else 'Z';
    --led(6)   <= '0' when (led_buf(6) = '1') else 'Z';
    --led(5)   <= '0' when (led_buf(5) = '1') else 'Z';
    --led(4)   <= '0' when (led_buf(4) = '1') else 'Z';
    led(3) <= '0' when (led_buf(3) = '1') else 'Z';
    led(2) <= '0' when (led_buf(2) = '1') else 'Z';
    led(1) <= '0' when (led_buf(1) = '1') else 'Z';
    led(0) <= '0' when (led_buf(0) = '1') else 'Z';
    --    o_sck_rx <= i_sck_rx;
    ------------------------------------------
    --  LED
    ------------------------------------------

    label_process_led : process(sys_clk, reset) is
    begin
        if reset = '1' then
            count   <= (others => '0');
            led_buf <= (others => '0');
        elsif rising_edge(sys_clk) then
            count <= count + 1;
            if To_integer(count) = 5000000 then

                led_buf <= not led_buf;
                count   <= (others => '0');

            end if;
        end if;
    end process;

    --    ------------------------------------------------
    --    -- 
    --    --------------------------------------------------
    --
    --    osc_clk : IBUFGDS port map(O => sys_clk_input, I => sys_clkp, IB => sys_clkn);
    --
    --    ------------------------------------------
    --    --  clock divider
    --    ------------------------------------------
    --
    --    label_clock : process(sys_clk_input, reset) is
    --    begin
    --        if reset = '1' then
    --            
    --            count_clock <= (others => '0');
    --            sys_clk_in     <= '0';
    --
    --        elsif rising_edge(sys_clk_input) then
    --
    --            count_clock <= count_clock + 1;
    --
    --            if To_integer(count_clock) = 1 then
    --                sys_clk_in     <= not sys_clk_in;
    --                count_clock <= (others => '0');
    --
    --            end if;
    --        end if;
    --    end process;
    --
    --    label_buffg : BUFG port map(I => sys_clk_in, O => sys_clk);

    ------------------------------------------
    --  PLL MMCM
    ------------------------------------------

    label_generate_complex_clock : if ads_7049_complex_clock = '1' generate
        label_clk_mmcm : entity work.clk_wiz_0_k160
            port map(
                clk_out1  => sys_clk,
                clk_out2  => clk_32Mhz,
                locked    => locked,
                clk_in1_p => sys_clkp,
                clk_in1_n => sys_clkn
            );
    end generate label_generate_complex_clock;

    label_generate : if ads_7049_complex_clock = '0' generate
        label_clk_mmcm : entity work.clk_wiz_0_k160
            port map(
                clk_out1  => sys_clk,
                clk_out2  => open,
                locked    => locked,
                clk_in1_p => sys_clkp,
                clk_in1_n => sys_clkn
            );

        clk_32Mhz <= sys_clk;
    end generate label_generate;

    ------------------------------------------
    -- Cycle spectrum, DAC121S, integration time
    ------------------------------------------

    label_cycle_spectrum : entity work.cycle_spectrum
        port map(
            sys_clk                => sys_clk,
            reset                  => reset,
            o_clk_synchro_spectrum => clk_synchro_spectrum
        );

    --    label_Cycle_spectrum : process(sys_clk, reset) is
    --    begin
    --        if reset = '1' then
    --            count_synchro_spectrum <= (others => '0');
    --            clk_synchro_spectrum   <= '0';
    --        elsif rising_edge(sys_clk) then
    --            count_synchro_spectrum <= count_synchro_spectrum + 1;
    --            if To_integer(count_synchro_spectrum) >= 20000000 then
    --                clk_synchro_spectrum   <= not clk_synchro_spectrum;
    --                count_synchro_spectrum <= (others => '0');
    --            end if;
    --        end if;
    --    end process;

    label_clock_1KHz : process(sys_clk, reset) is
    begin
        if reset = '1' then
            count_clock_1KHz <= (others => '0');
            clk_1KHz         <= '0';
        elsif rising_edge(sys_clk) then
            count_clock_1KHz <= count_clock_1KHz + 1;
            --if To_integer(count_clock_1KHz) >= 10000 then
            if To_integer(count_clock_1KHz) >= 10000 then
                clk_1KHz         <= not clk_1KHz;
                count_clock_1KHz <= (others => '0');
            end if;
        end if;
    end process;

    label_clock_enable : process(sys_clk, reset) is
    begin
        if reset = '1' then
            cmpt_sequencer <= (others => '0');

        elsif rising_edge(sys_clk) then
            cmpt_sequencer <= cmpt_sequencer + 1;
        end if;
    end process;

    enable_clock_1KHz <= cmpt_sequencer(14) and cmpt_sequencer(13) and cmpt_sequencer(12) and cmpt_sequencer(11) and cmpt_sequencer(10) and cmpt_sequencer(9) and cmpt_sequencer(8) and cmpt_sequencer(7) and cmpt_sequencer(6) and cmpt_sequencer(5) and cmpt_sequencer(4) and cmpt_sequencer(3) and cmpt_sequencer(2) and cmpt_sequencer(1) and cmpt_sequencer(0);

    ------------------------------------------
    --  global conf
    ------------------------------------------

    reset_wire <= reg_global(0);
    reset      <= (not locked) or reset_wire;

    i_Start_Capture    <= (others => reg_global(1));
    enable_high_filter <= (others => reg_global(30));

    continuous_injection <= reg_global(29);

    ------------------------------------------
    -- Instantiate the okHost and connect endpoints
    ------------------------------------------

    okHI : okHost
        port map(
            okUH  => okUH,
            okHU  => okHU,
            okUHU => okUHU,
            okAA  => okAA,              --removed for simulation
            okClk => okClk,
            okHE  => okHE,
            okEH  => okEH
        );

    ------------------------------------------
    --  FIFO pipe_in Injection
    ------------------------------------------

    fifo_pipe_in_injection : entity work.fifo_pipe_out_w32_1024_r32_1024_k160
        port map(
            rst         => reset,
            wr_clk      => okClk,
            rd_clk      => clk_32Mhz,
            din         => pipe_in_injection_din_fifo,
            wr_en       => pipe_in_injection_wr_en_fifo,
            rd_en       => pipe_in_injection_rd_en_fifo,
            dout        => pipe_in_injection_dout_fifo,
            full        => open,
            empty       => pipe_in_injection_empty_fifo,
            valid       => pipe_in_injection_valid_fifo,
            wr_rst_busy => open,
            rd_rst_busy => open
        );

    ------------------------------------------
    --  Injection
    ------------------------------------------  

    label_Injection : entity work.Injection
        port map(
            --global
            reset                  => reset,
            i_clk_fast             => clk_32Mhz,
            --from pipe in fifo Injection
            i_continuous_injection => continuous_injection,
            o_pipe_in_rd_en        => pipe_in_injection_rd_en_fifo,
            i_pipe_in_empty        => pipe_in_injection_empty_fifo,
            i_pipe_in_valid        => pipe_in_injection_valid_fifo,
            i_pipe_in_dout         => signed(pipe_in_injection_dout_fifo(11 downto 0)),
            --output injection to CDC
            o_injection_started    => injection_started,
            o_data                 => data_fast_injection,
            o_ready                => ready_fast_injection
        );

    ------------------------------------------
    -- ADS7049 receivers
    -- ADC comment: ADC IO driver disabled/commented out.
    ------------------------------------------
    -- generate_ADC_enabled : if Enable_ADC_Driver generate
    --     generate_label_Rx_fe_ads7049_and : for N in 0 to Detector_Number - 1 generate
    --         label_read_ADC : entity work.Rx_fe_ads7049_and
    --             port map(
    --                 clk        => clk_32Mhz,
    --                 rst        => reset,
    --                 o_sck      => o_sck(N),
    --                 o_cs_n     => o_cs_n(N),
    --                 i_sdi      => i_sdi(N),
    --                 o_data_rx  => data_rx(N),
    --                 o_ready_rx => ready_rx(N)
    --             );
    --     end generate generate_label_Rx_fe_ads7049_and;
    -- end generate generate_ADC_enabled;

    data_rx  <= (others => (others => '0'));
    ready_rx <= (others => '0');

    ------------------------------------------
    -- Capture ADC data on the rising edge before the CDC input
    ------------------------------------------
    generate_ADC_keeper_enabled : if Enable_ADC_Driver generate
        generate_label_keep_data_from_ADC : for N in 0 to Detector_Number - 1 generate
            label_keep_data_from_ADC : process(clk_32Mhz, reset) is
            begin
                if reset = '1' then
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
    end generate generate_ADC_keeper_enabled;

    generate_ADC_keeper_disabled : if not Enable_ADC_Driver generate
        data_rx_keeped  <= (others => (others => '0'));
        ready_rx_keeped <= (others => '0');
    end generate generate_ADC_keeper_disabled;

    ------------------------------------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------------------------------------------------------

    ------------------------------------------
    --  MUX ADC OR Injection
    ------------------------------------------  
    generate_label_mux_science_data : for N in 0 to Detector_Number - 1 generate
        label_mux_science_data : i_data_CDC(N) <= signed(data_rx_keeped(N)) when (Enable_ADC_Driver and (reg_global(31) = '1')) else ('0' & data_fast_injection & b"000");
    end generate generate_label_mux_science_data;

    generate_label : for N in 0 to Detector_Number - 1 generate
        label_mux_science_ready : i_ready_CDC(N) <= ready_rx_keeped(N) when (Enable_ADC_Driver and (reg_global(31) = '1')) else ready_fast_injection;
    end generate generate_label;
    ------------------------------------------
    --  EP
    ------------------------------------------
    generate_EP : for N in 0 to Detector_Number - 1 generate
        label_Ep : entity work.EP
            port map(
                -- global
                i_clk_slow                   => sys_clk,
                i_clk_fast                   => clk_32Mhz,
                i_reset                      => reset,
                -- ADC survey
                --i_data_rx_keeped          => signed(data_rx_keeped),
                -- global select spectrum
                i_clk_synchro_spectrum       => clk_synchro_spectrum,
                i_detector_number            => To_unsigned(N, Detector_Number_Width),
                --i_filter_number              => std_logic_vector(To_unsigned(N, 2)),
                -- input param trigger pick detect energy
                i_gain                       => i_gain(N),
                i_TH_ADC                     => TH_ADC,
                i_TH_rise                    => TH_rise,
                i_TH_fall                    => TH_fall,
                --i_enable_erase            => enable_erase,
                i_TH_rise_high_frequency     => TH_rise_high_frequency,
                i_TH_fall_high_frequency     => TH_fall_high_frequency,
                -- input Data science
                i_ready_CDC                  => i_ready_CDC(N),
                i_data_CDC                   => i_data_CDC(N),
                -- out view 
                --o_data_after_gain         => data_after_gain(N),
                o_ready_after_gain           => ready_after_gain(N),
                -- input coef filter
                i_enable_high_filter         => enable_high_filter(N),
                i_coef_fir                   => coef_fir(N),
                i_coef_fir_ready             => i_coef_fir_ready(N),
                -- out view
                o_data_before_filter         => data_before_filter(N),
                -- out spectrum to fifo pipe out
                o_pipe_out_spectrum_din      => o_pipe_out_spectrum_din(N),
                o_pipe_out_spectrum_wr_en    => o_pipe_out_spectrum_wr_en(N),
                o_spectrum_count_pulse       => spectrum_count_pulse(N),
                o_data_after_energy_level    => data_after_energy_level(N),
                o_pipe_out_spectrum_sd_din   => o_pipe_out_spectrum_sd_din(N),
                o_pipe_out_spectrum_sd_wr_en => o_pipe_out_spectrum_sd_wr_en(N),
                o_spectrum_sd_count_pulse    => spectrum_sd_count_pulse(N)
            );
    end generate generate_EP;

    ------------------------------------------
    --  mux data spectrum packet
    ------------------------------------------ 

    --    pipe_out_spectrum_din   <= o_pipe_out_spectrum_din(0) when o_pipe_out_spectrum_wr_en(0) = '1' else o_pipe_out_spectrum_din(1) when o_pipe_out_spectrum_wr_en(1) = '1';
    --    pipe_out_spectrum_wr_en <= o_pipe_out_spectrum_wr_en(0) or o_pipe_out_spectrum_wr_en(1);

    lebel_process_mux_data_spectrum_packet : process(sys_clk, reset) is
    begin
        if reset = '1' then
            -- 1. Valeurs par défaut si aucun wr_en n'est actif
            pipe_out_spectrum_wr_en <= '0';
            pipe_out_spectrum_din   <= (others => '0');

        elsif rising_edge(sys_clk) then
            -- 1. Valeurs par défaut si aucun wr_en n'est actif
            pipe_out_spectrum_wr_en <= '0';
            pipe_out_spectrum_din   <= (others => '0');

            -- 2. Boucle de priorité (0 à Detector_Number-1)
            -- Le dernier canal avec wr_en='1' l'emporte
            for i in 0 to (Detector_Number - 1) loop
                if o_pipe_out_spectrum_wr_en(i) = '1' then
                    pipe_out_spectrum_din   <= o_pipe_out_spectrum_din(i);
                    pipe_out_spectrum_wr_en <= '1'; -- Devient '1' dès qu'au moins un canal est actif
                end if;
            end loop;

        end if;
    end process;

    ------------------------------------------
    --  mux data spectrum packet SD
    ------------------------------------------ 

    --    pipe_out_spectrum_sd_din   <= o_pipe_out_spectrum_sd_din(0) when o_pipe_out_spectrum_sd_wr_en(0) = '1' else o_pipe_out_spectrum_sd_din(1) when o_pipe_out_spectrum_sd_wr_en(1) = '1';
    --    pipe_out_spectrum_sd_wr_en <= o_pipe_out_spectrum_sd_wr_en(0) or o_pipe_out_spectrum_sd_wr_en(1);

    lebel_process_mux_data_spectrum_packet_SD : process(sys_clk, reset) is
    begin
        if reset = '1' then
            -- 1. Valeurs par défaut si aucun wr_en n'est actif
            pipe_out_spectrum_sd_wr_en <= '0';
            pipe_out_spectrum_sd_din   <= (others => '0');

        elsif rising_edge(sys_clk) then
            -- 1. Valeurs par défaut (si aucun signal wr_en n'est actif)
            pipe_out_spectrum_sd_wr_en <= '0';
            pipe_out_spectrum_sd_din   <= (others => '0');

            -- 2. Boucle de priorité de 0 à Detector_Number-1
            for i in 0 to (Detector_Number - 1) loop
                if o_pipe_out_spectrum_sd_wr_en(i) = '1' then
                    pipe_out_spectrum_sd_din   <= o_pipe_out_spectrum_sd_din(i);
                    pipe_out_spectrum_sd_wr_en <= '1'; -- Reste à '1' si au moins un canal est actif
                end if;
            end loop;

        end if;
    end process;

    ------------------------------------------
    --  process 
    ------------------------------------------ 

    lebel_process : process(sys_clk, reset) is
    begin
        if reset = '1' then
            pipe_out_spectrum_wr_en_fifo    <= ('0');
            pipe_out_spectrum_din_fifo      <= (others => '0');
            pipe_out_spectrum_sd_wr_en_fifo <= ('0');
            pipe_out_spectrum_sd_din_fifo   <= (others => '0');

        elsif rising_edge(sys_clk) then
            pipe_out_spectrum_wr_en_fifo <= pipe_out_spectrum_wr_en;
            pipe_out_spectrum_din_fifo   <= pipe_out_spectrum_din;

            pipe_out_spectrum_sd_wr_en_fifo <= pipe_out_spectrum_sd_wr_en;
            pipe_out_spectrum_sd_din_fifo   <= pipe_out_spectrum_sd_din;

        end if;
    end process;

    ------------------------------------------
    --  FSM raw data
    ------------------------------------------
    generate_label_FSM_raw_data : for N in 0 to Detector_Number - 1 generate
        label_FSM_raw_data : entity work.FSM_raw_data
            port map(
                --global
                i_clk_slow                     => sys_clk,
                i_reset                        => reset,
                --remote FSM raw data
                i_continuous_injection         => continuous_injection,
                i_level_trigger                => i_level_trigger(N),
                i_Start_Capture                => i_Start_Capture(N),
                --input
                i_din_fifo_raw_data            => din_fifo_raw_data(N),
                i_ready                        => ready_after_gain(N),
                --output
                o_din_fifo_pipe_out_raw_data   => din_fifo_pipe_out_raw_data(N),
                o_wr_en_fifo_pipe_out_raw_data => wr_en_fifo_pipe_out_raw_data(N),
                i_empty_fifo_pipe_out_raw_data => empty_raw_data
            );
    end generate generate_label_FSM_raw_data;

    empty_raw_data <= and_reduce(empty_fifo_pipe_out_raw_data); -- and_reduce fait un ET logique sur tous les bits d’un vecteur.

    --    generate_din_fifo_raw_data : for N IN 1 downto 0 generate
    --        label_din_fifo_raw_data : din_fifo_raw_data(N) <= data_after_energy_level(N) & data_before_filter(N);
    --    end generate generate_din_fifo_raw_data;

    ------------------------------------------
    --  process generate_din_fifo_raw_data
    ------------------------------------------ 
    generate_din_fifo_raw_data : for N in 0 to Detector_Number - 1 generate
        label_trigger : process(sys_clk, reset) is
        begin
            if reset = '1' then
                din_fifo_raw_data(N) <= (others => '0');
            elsif rising_edge(sys_clk) then
                din_fifo_raw_data(N) <= data_after_energy_level(N) & data_before_filter(N);
            end if;
        end process;
    end generate generate_din_fifo_raw_data;

    ------------------------------------------
    --  process trigger raw data
    ------------------------------------------ 
    generate_label_trigger : for N in 0 to Detector_Number - 1 generate
        label_trigger : process(sys_clk, reset) is
        begin
            if reset = '1' then
                i_level_trigger(N) <= '0';
            elsif rising_edge(sys_clk) then
                --  test if injection mode to avoid trigger on value 0
                if (signed(ep01wire(15 downto 0)) < data_before_filter(N) and injection_started = '1' and reg_global(31) = '0') or (signed(ep01wire(15 downto 0)) < data_before_filter(N) and reg_global(31) = '1') then
                    i_level_trigger(N) <= '1';
                else
                    i_level_trigger(N) <= '0';
                end if;
            end if;
        end process;
    end generate generate_label_trigger;

    ------------------------------------------
    --  remote DAC121S101_Driver
    ------------------------------------------
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

    ------------------------------------------
    --  FIFO pipe_out data science
    ------------------------------------------
    generate_fifo_pipe_out_science_raw_data : for N in 0 to Detector_Number - 1 generate
        fifo_pipe_out_science : entity work.fifo_pipe_out_w32_2048_r32_2048_k160
            port map(
                rst           => reset,
                wr_clk        => sys_clk,
                rd_clk        => okClk,
                din           => std_logic_vector(din_fifo_pipe_out_raw_data(N)),
                wr_en         => wr_en_fifo_pipe_out_raw_data(N),
                rd_en         => rd_en_fifo_pipe_out_raw_data(N),
                dout          => dout_fifo_pipe_out_raw_data(N),
                full          => open,
                empty         => empty_fifo_pipe_out_raw_data(N),
                valid         => open,
                rd_data_count => rd_fifo_pipe_out_data_count_raw_data(N),
                wr_rst_busy   => open,
                rd_rst_busy   => open
            );
    end generate generate_fifo_pipe_out_science_raw_data;
    ------------------------------------------
    --  FIFO pipe_out spectrum
    ------------------------------------------

    fifo_pipe_out_spectrum : entity work.fifo_pipe_out_w32_8192_r32_8192_k160
        port map(
            rst           => reset,
            wr_clk        => sys_clk,
            rd_clk        => okClk,
            din           => pipe_out_spectrum_din_fifo,
            wr_en         => pipe_out_spectrum_wr_en_fifo,
            rd_en         => pipe_out_spectrum_rd_en,
            dout          => pipe_out_spectrum_dout,
            full          => open,
            empty         => open,
            valid         => open,
            rd_data_count => pipe_out_rd_data_count_spectrum,
            wr_rst_busy   => open,
            rd_rst_busy   => open
        );

    ------------------------------------------
    --  FIFO pipe_out spectrum standard definition
    ------------------------------------------

    fifo_pipe_out_spectrum_SD : entity work.fifo_pipe_out_w32_4096_r32_4096_k160
        port map(
            rst           => reset,
            wr_clk        => sys_clk,
            rd_clk        => okClk,
            din           => pipe_out_spectrum_sd_din_fifo,
            wr_en         => pipe_out_spectrum_sd_wr_en_fifo,
            rd_en         => pipe_out_spectrum_sd_rd_en,
            dout          => pipe_out_spectrum_sd_dout,
            full          => open,
            empty         => open,
            valid         => open,
            rd_data_count => pipe_out_rd_data_count_spectrum_sd,
            wr_rst_busy   => open,
            rd_rst_busy   => open
        );

    ------------------------------------------
    --  FSM pipe_in config in co coef FIR filter
    ------------------------------------------

    label_FSM_pipe_in_config : entity work.FSM_read_config
        port map(
            i_clk_slow              => sys_clk,
            i_reset                 => reset,
            i_pipe_in_config_empty  => pipe_in_config_empty,
            i_pipe_in_config_valid  => pipe_in_config_valid,
            i_pipe_in_config_dout   => signed(pipe_in_config_dout),
            i_pipe_in_rd_data_count => pipe_in_confi_rd_data_count,
            o_pipe_in_config_rd_en  => pipe_in_config_rd_en,
            ----
            o_coef_fir_ready        => coef_fir_ready,
            o_coef_fir              => coef_fir,
            ---
            o_reg_config            => reg_config,
            ----
            o_gain                  => i_gain
        );

    ------------------------------------------
    --  wrappe FSM_read_config to register
    ------------------------------------------

    i_coef_fir_ready <= (others => coef_fir_ready);

    --i_gain                 <= gain(0);
    --i_gain_high_frequency  <= gain(1);
    ----------------------------------
    --reg_global               <= reg_config(0);
    ep01wire               <= reg_config(1);
    TH_rise                <= reg_config(2);
    TH_fall                <= reg_config(3);
    TH_ADC                 <= reg_config(4);
    --level_DAC121S          <= reg_config(5);
    TH_rise_high_frequency <= reg_config(6);
    TH_fall_high_frequency <= reg_config(7);

    ------------------------------------------
    --  FIFO pipe_in config
    ------------------------------------------

    fifo_pipe_in_config : entity work.fifo_pipe_in_w32_1024_r32_1024_k160
        port map(
            rst           => reset,
            wr_clk        => okClk,
            rd_clk        => sys_clk,
            din           => pipe_in_config_din,
            wr_en         => pipe_in_config_wr_en,
            rd_en         => pipe_in_config_rd_en,
            dout          => pipe_in_config_dout,
            full          => open,
            empty         => pipe_in_config_empty,
            valid         => pipe_in_config_valid,
            rd_data_count => pipe_in_confi_rd_data_count,
            wr_rst_busy   => open,
            rd_rst_busy   => open
        );

    ------------------------------------------
    --  wire out for FIFO pipe out science, wire out for FIFO pipe out spectrum
    ------------------------------------------
    generate_label_process_inter_wire : for N in 0 to Detector_Number - 1 generate
        label_process_inter_wire : process(sys_clk, reset) is
        begin
            if reset = '1' then
                fifo_count_raw_data(N)      <= (others => '0');
                fifo_data_count_spectrum    <= (others => '0');
                reg_spectrum_count_pulse(N) <= (others => '0');
                fifo_data_count_spectrum_sd <= (others => '0');
            --ep23wire <= (others => '0');
            --ep24wire <= (others => '0');
            elsif rising_edge(sys_clk) then
                fifo_count_raw_data(N)         <= "000000000000000000000" & rd_fifo_pipe_out_data_count_raw_data(N);
                fifo_data_count_spectrum       <= "000000000000000000" & pipe_out_rd_data_count_spectrum;
                reg_spectrum_count_pulse(N)    <= spectrum_count_pulse(N);
                fifo_data_count_spectrum_sd    <= "0000000000000000000" & pipe_out_rd_data_count_spectrum_sd;
                reg_spectrum_sd_count_pulse(N) <= spectrum_sd_count_pulse(N);

                --ep23wire <= "000000000000000000000" & rd_fifo_pipe_out_data_count_raw_data(1);
                --ep24wire <= "000000000000000000000" & pipe_out_rd_data_count_spectrum(1);

            end if;
        end process;
    end generate generate_label_process_inter_wire;

    --    ------------------------------------------
    --    --  wire input init  
    --    ------------------------------------------
    --
    --    label_process_inter_wire : process(sys_clk, reset) is
    --    begin
    --        if reset = '1' then
    --        TH_ADC <= x"00007FFF";
    --        elsif rising_edge(sys_clk) then
    --            TH_ADC <= TH_ADC_wire;
    --        end if;
    --    end process;

    --ep25wire <= spectrum_count_pulse(1);

    ---------------------------------------------------------------------
    --  Front Panel for filter 0 and globald drive for high definition
    -------------------------------------------------------------------------

    --  okwire OR
    okWO : okWireOR generic map(N => 24) port map(okEH => okEH, okEHx => okEHx);
    --  reset, start_capture
    ep00 : okWireIn port map(okHE => okHE, ep_addr => x"00", ep_dataout => reg_global);
    --  level DAC121S 
    ep06 : okWireIn port map(okHE => okHE, ep_addr => x"06", ep_dataout => level_DAC121S);
    --  read wire out for FIFO pipe out science.
    ep20 : okWireOut port map(okHE => okHE, okEH => okEHx(1 * 65 - 1 downto 0 * 65), ep_addr => x"20", ep_datain => fifo_count_raw_data(0));
    --  read wire out for FIFO pipe out spectrum.
    ep21 : okWireOut port map(okHE => okHE, okEH => okEHx(2 * 65 - 1 downto 1 * 65), ep_addr => x"21", ep_datain => fifo_data_count_spectrum);
    --  read wire out spectrum_count_pulse
    ep22 : okWireOut port map(okHE => okHE, okEH => okEHx(3 * 65 - 1 downto 2 * 65), ep_addr => x"22", ep_datain => reg_spectrum_count_pulse(0));
    --  pipe in injection
    ep80 : okPipeIn port map(okHE => okHE, okEH => okEHx(4 * 65 - 1 downto 3 * 65), ep_addr => x"80", ep_write => pipe_in_injection_wr_en_fifo, ep_dataout => pipe_in_injection_din_fifo);
    --  pipe in config
    ep81 : okPipeIn port map(okHE => okHE, okEH => okEHx(5 * 65 - 1 downto 4 * 65), ep_addr => x"81", ep_write => pipe_in_config_wr_en, ep_dataout => pipe_in_config_din);
    --  pipe out raw data
    epA1 : okPipeOut port map(okHE => okHE, okEH => okEHx(6 * 65 - 1 downto 5 * 65), ep_addr => x"A1", ep_read => rd_en_fifo_pipe_out_raw_data(0), ep_datain => dout_fifo_pipe_out_raw_data(0));
    --  pipe out spectrum
    epA2 : okPipeOut port map(okHE => okHE, okEH => okEHx(7 * 65 - 1 downto 6 * 65), ep_addr => x"A2", ep_read => pipe_out_spectrum_rd_en, ep_datain => pipe_out_spectrum_dout);

    --------------------------------------------------------------------------
    --  Front Panel for filter 1 for high definition
    --------------------------------------------------------------------------

    --  read wire out for FIFO pipe out science.
    ep23 : okWireOut port map(okHE => okHE, okEH => okEHx(8 * 65 - 1 downto 7 * 65), ep_addr => x"23", ep_datain => fifo_count_raw_data(1));
    --  read wire out read wire out spectrum_count_pulse
    ep25 : okWireOut port map(okHE => okHE, okEH => okEHx(9 * 65 - 1 downto 8 * 65), ep_addr => x"25", ep_datain => reg_spectrum_count_pulse(1));
    --  pipe in config
    --  pipe out raw data
    epA3 : okPipeOut port map(okHE => okHE, okEH => okEHx(10 * 65 - 1 downto 9 * 65), ep_addr => x"A3", ep_read => rd_en_fifo_pipe_out_raw_data(1), ep_datain => dout_fifo_pipe_out_raw_data(1));
    --  pipe out spectrum

    -----------------------------------------------------------------------------
    --  Front Panel only for standard definition
    -----------------------------------------------------------------------------

    --  pipe out spectrum sd
    epA5 : okPipeOut port map(okHE => okHE, okEH => okEHx(11 * 65 - 1 downto 10 * 65), ep_addr => x"A5", ep_read => pipe_out_spectrum_sd_rd_en, ep_datain => pipe_out_spectrum_sd_dout);
    --  read wire out for FIFO pipe out spectrum sd
    ep26 : okWireOut port map(okHE => okHE, okEH => okEHx(12 * 65 - 1 downto 11 * 65), ep_addr => x"26", ep_datain => fifo_data_count_spectrum_sd);
    --  read wire out spectrum_count_pulse sd
    ep28 : okWireOut port map(okHE => okHE, okEH => okEHx(13 * 65 - 1 downto 12 * 65), ep_addr => x"28", ep_datain => reg_spectrum_sd_count_pulse(0));
    --  read wire out spectrum_count_pulse sd
    ep29 : okWireOut port map(okHE => okHE, okEH => okEHx(14 * 65 - 1 downto 13 * 65), ep_addr => x"29", ep_datain => reg_spectrum_sd_count_pulse(1));

    -----------------------------------------------------------------------------
    --  Extanded to seven
    -----------------------------------------------------------------------------

    --  pipe out raw data
    --  read wire out for FIFO pipe out science.
    ep30 : okWireOut port map(okHE => okHE, okEH => okEHx(15 * 65 - 1 downto 14 * 65), ep_addr => x"30", ep_datain => fifo_count_raw_data(2));
    epA6 : okPipeOut port map(okHE => okHE, okEH => okEHx(16 * 65 - 1 downto 15 * 65), ep_addr => x"A6", ep_read => rd_en_fifo_pipe_out_raw_data(2), ep_datain => dout_fifo_pipe_out_raw_data(2));

    --  read wire out for FIFO pipe out science.
    ep31 : okWireOut port map(okHE => okHE, okEH => okEHx(17 * 65 - 1 downto 16 * 65), ep_addr => x"31", ep_datain => fifo_count_raw_data(3));
    epA7 : okPipeOut port map(okHE => okHE, okEH => okEHx(18 * 65 - 1 downto 17 * 65), ep_addr => x"A7", ep_read => rd_en_fifo_pipe_out_raw_data(3), ep_datain => dout_fifo_pipe_out_raw_data(3));

    -- Detectors 5 to 7: raw FIFO counters and data pipes.
    ep32 : okWireOut port map(okHE => okHE, okEH => okEHx(19 * 65 - 1 downto 18 * 65), ep_addr => x"32", ep_datain => fifo_count_raw_data(4));
    epA8 : okPipeOut port map(okHE => okHE, okEH => okEHx(20 * 65 - 1 downto 19 * 65), ep_addr => x"A8", ep_read => rd_en_fifo_pipe_out_raw_data(4), ep_datain => dout_fifo_pipe_out_raw_data(4));

    ep33 : okWireOut port map(okHE => okHE, okEH => okEHx(21 * 65 - 1 downto 20 * 65), ep_addr => x"33", ep_datain => fifo_count_raw_data(5));
    epA9 : okPipeOut port map(okHE => okHE, okEH => okEHx(22 * 65 - 1 downto 21 * 65), ep_addr => x"A9", ep_read => rd_en_fifo_pipe_out_raw_data(5), ep_datain => dout_fifo_pipe_out_raw_data(5));

    ep34 : okWireOut port map(okHE => okHE, okEH => okEHx(23 * 65 - 1 downto 22 * 65), ep_addr => x"34", ep_datain => fifo_count_raw_data(6));
    epAA : okPipeOut port map(okHE => okHE, okEH => okEHx(24 * 65 - 1 downto 23 * 65), ep_addr => x"AA", ep_read => rd_en_fifo_pipe_out_raw_data(6), ep_datain => dout_fifo_pipe_out_raw_data(6));

end arch;
