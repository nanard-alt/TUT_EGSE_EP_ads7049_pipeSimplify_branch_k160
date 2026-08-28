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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.UT_EGSE_EP_Package.all;

entity EP is
    port(
        -- global
        i_clk_slow                   : in  std_logic; -- horloge systeme lente
        i_clk_fast                   : in  std_logic; -- horloge rapide ADC/injection
        i_reset                      : in  std_logic; -- reset actif a 0

        -- synchronisation et identification du detecteur
        i_clk_synchro_spectrum       : in  std_logic; -- signal periodique de synchronisation/lecture des spectres
        i_detector_number            : in  unsigned; -- numero du detecteur courant

        -- configuration gain et seuils Energy_level
        i_gain                       : in  Array_config_16unsignedx2_type; -- gains 16 bits pour filtre basse et haute frequence
        i_TH_ADC                     : in  std_logic_vector(15 downto 0); -- seuil de surveillance ADC avant filtrage
        i_TH_rise                    : in  std_logic_vector(15 downto 0); -- seuil montee Energy_level basse frequence
        i_TH_fall                    : in  std_logic_vector(15 downto 0); -- seuil descente Energy_level basse frequence
        i_TH_rise_high_frequency     : in  std_logic_vector(15 downto 0); -- seuil montee Energy_level haute frequence
        i_TH_fall_high_frequency     : in  std_logic_vector(15 downto 0); -- seuil descente Energy_level haute frequence

        -- entree echantillon provenant de l'ADC ou injection
        i_ready_CDC                  : in  std_logic; -- pulse indiquant que i_data_CDC est valide
        i_data_CDC                   : in  signed(15 downto 0); -- echantillon 16 bits avant CDC optionnel

        -- configuration FIR et selection filtre
        i_enable_high_filter         : in  std_logic; -- selection sortie filtre: 0 basse frequence, 1 haute frequence
        i_coef_fir                   : in  Array_Array_config_32x16_type; -- coefficients FIR pour les deux filtres du detecteur
        i_coef_fir_ready             : in  std_logic; -- pulse indiquant que les coefficients FIR sont charges
        i_standard_energy_threshold  : in  Array_Array_config_10x16_type; -- seuils standard energy pour les deux filtres du detecteur

        -- sorties de surveillance chaine energie
        o_data_before_filter         : out signed(15 downto 0); -- echantillon avant FIR du filtre selectionne
        o_ready_after_gain           : out std_logic; -- pulse apres gain du filtre selectionne
        o_data_after_energy_level    : out signed(15 downto 0); -- echantillon apres Energy_level du filtre selectionne

        -- sortie spectrum haute definition vers FIFO PipeOut
        o_pipe_out_spectrum_din      : out std_logic_vector(31 downto 0); -- mot spectrum HD 32 bits vers FIFO PipeOut
        o_pipe_out_spectrum_wr_en    : out std_logic; -- demande d'ecriture spectrum HD dans FIFO PipeOut

        -- sortie spectrum standard definition vers FIFO PipeOut
        o_pipe_out_spectrum_sd_din   : out std_logic_vector(31 downto 0); -- mot spectrum SD 32 bits vers FIFO PipeOut
        o_pipe_out_spectrum_sd_wr_en : out std_logic -- demande d'ecriture spectrum SD dans FIFO PipeOut
    );
end entity EP;

architecture RTL of EP is

    signal data_before_filter_CDC  : signed(15 downto 0);
    signal ready_before_filter_CDC : std_logic;

    signal ready_before_filter     : std_logic_vector(Filter_Number - 1 downto 0);
    signal data_before_filter      : Array_config_16signedx2_type;
    signal data_after_filter       : Array_config_16signedx2_type;
    signal Energy_level_max        : Array_config_16signedx2_type;
    signal readyEnergy_level_max   : std_logic_vector(Filter_Number - 1 downto 0);
    signal data_after_energy_level : Array_config_16signedx2_type;

    signal ready_after_filter : std_logic_vector(Filter_Number - 1 downto 0);
    signal data_after_gain    : Array_config_16signedx2_type;
    signal ready_after_gain   : std_logic_vector(Filter_Number - 1 downto 0);

    signal ready_energy_level_max_sd : std_logic_vector(Filter_Number - 1 downto 0);
    signal energy_level_max_sd       : Array_config_16signedx2_type;

    signal pipe_out_spectrum_din   : Array_config_32stdx2_type;
    signal pipe_out_spectrum_wr_en : std_logic_vector(Filter_Number - 1 downto 0);

    signal pipe_out_spectrum_sd_din   : Array_config_32stdx2_type;
    signal pipe_out_spectrum_sd_wr_en : std_logic_vector(Filter_Number - 1 downto 0);

    signal TH_rise : Array_config_16stdx2_type;
    signal TH_fall : Array_config_16stdx2_type;

    --signal gain : Array_config_32unsignedx2_type;

begin

    ------------------------------------------
    --  CDC after Injection or ADC
    ------------------------------------------

    label_generate_complex_clock : if ads_7049_complex_clock = '1' generate
        label_cdc : entity work.Fast_to_Slow_CDC
            port map(
                -- global
                i_reset    => i_reset,
                i_clk_fast => i_clk_fast,
                i_clk_slow => i_clk_slow,
                -- synchronisation ready
                i_ready    => i_ready_CDC,
                o_ready    => ready_before_filter_CDC, --ready_slow,

                -- donnees ADC ou injection
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

    generate_input_filter_copy : for N in 0 to Filter_Number - 1 generate
        data_before_filter(N)  <= data_before_filter_CDC;
        ready_before_filter(N) <= ready_before_filter_CDC;
    end generate generate_input_filter_copy;

    ------------------------------------------
    --  FIR filter
    ------------------------------------------
    generate_label_FIR_filter : for N in 0 to Filter_Number - 1 generate
        label_FIR_filter : entity work.FIR_filter
            port map(
                -- global
                i_clk_slow       => i_clk_slow,
                i_reset          => i_reset,
                -- configuration des coefficients FIR
                i_coef_fir       => i_coef_fir(N),
                i_coef_fir_ready => i_coef_fir_ready,
                -- entree echantillon provenant de l'ADC ou injection
                i_data           => data_before_filter(N),
                i_ready          => ready_before_filter(N),
                -- sortie echantillon filtre vers gain
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
    generate_label_gain : for N in 0 to Filter_Number - 1 generate
        label_gain : entity work.gain
            port map(
                -- global
                i_clk_slow           => i_clk_slow,
                i_reset              => i_reset,
                -- configuration du gain
                i_gain               => i_gain(N),
                -- entree echantillon filtre provenant de FIR_filter
                i_data_after_filter  => data_after_filter(N),
                i_ready_after_filter => ready_after_filter(N),
                -- sortie echantillon amplifie vers Energy_level
                o_data_after_gain    => data_after_gain(N),
                o_ready_after_gain   => ready_after_gain(N)
            );
    end generate generate_label_gain;

    --gain(0) <= i_gain;
    --gain(1) <= i_gain_high_frequency;

    --o_data_after_gain  <= data_after_gain;
    o_ready_after_gain <= ready_after_gain(0) when i_enable_high_filter = '0' else ready_after_gain(1);

    ------------------------------------------
    --  Energy level
    ------------------------------------------
    generate_label_energy_level : for N in 0 to Filter_Number - 1 generate
        label_energy_level : entity work.Energy_level
            port map(
                -- global
                i_clk_slow                => i_clk_slow,
                i_reset                   => i_reset,
                -- surveillance ADC avant filtrage
                i_data_before_filter      => data_before_filter(N),
                -- entree detection energie apres filtrage
                i_data_after_filter       => data_after_gain(N),
                i_TH_ADC                  => i_TH_ADC,
                i_TH_rise                 => TH_rise(N),
                i_TH_fall                 => TH_fall(N),
                -- sortie niveau d'energie
                o_Energy_level_max        => Energy_level_max(N),
                o_readyEnergy_level_max   => readyEnergy_level_max(N),
                -- recopie du flux apres gain
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
    generate_lable_spectrum : for N in 0 to Filter_Number - 1 generate
        lable_spectrum : entity work.spectrum
            generic map(
                memory_add_size => 10,
                depth_memory    => 1024
            )
            port map(
                -- global
                i_clk_slow                => i_clk_slow,
                i_reset                   => i_reset,
                -- synchronisation et identification du spectre
                i_clk_synchro_spectrum    => i_clk_synchro_spectrum,
                i_detector_number         => i_detector_number,
                i_filter_number           => To_unsigned(N, Filter_Number_Width),
                -- entree depuis Energy_level
                i_Energy_level_max        => Energy_level_max(N),
                i_readyEnergy_level_max   => readyEnergy_level_max(N),
                -- sortie vers FIFO PipeOut spectrum HD
                o_pipe_out_spectrum_din   => pipe_out_spectrum_din(N),
                o_pipe_out_spectrum_wr_en => pipe_out_spectrum_wr_en(N)
            );
    end generate generate_lable_spectrum;

    o_pipe_out_spectrum_din   <= pipe_out_spectrum_din(0) when i_enable_high_filter = '0' else pipe_out_spectrum_din(1);
    o_pipe_out_spectrum_wr_en <= pipe_out_spectrum_wr_en(0) when i_enable_high_filter = '0' else pipe_out_spectrum_wr_en(1);

    ------------------------------------------
    --  detect standard energy
    ------------------------------------------
    generate_label_standard_energy : for N in 0 to Filter_Number - 1 generate
        label_standard_energy : entity work.detect_standard_energy
            port map(
                -- global
                i_clk_slow                  => i_clk_slow,
                i_reset                     => i_reset,
                -- configuration des seuils
                i_standard_energy_threshold => i_standard_energy_threshold(N),
                -- entree depuis Energy_level
                i_ready_energy_level_max    => readyEnergy_level_max(N),
                i_energy_level_max          => Energy_level_max(N),
                -- sortie vers construction du spectrum standard definition
                o_ready_energy_level_max_sd => ready_energy_level_max_sd(N),
                o_energy_level_max_sd       => energy_level_max_sd(N)
            );
    end generate generate_label_standard_energy;

    ------------------------------------------
    --  spectrum Standard definition
    ------------------------------------------
    generate_lable_spectrum_Standard_definition : for N in 0 to Filter_Number - 1 generate
        lable_spectrum_Standard_definition : entity work.spectrum
            generic map(
                memory_add_size => 3,
                depth_memory    => 8
            )
            port map(
                -- global
                i_clk_slow                => i_clk_slow,
                i_reset                   => i_reset,
                -- synchronisation et identification du spectre
                i_clk_synchro_spectrum    => i_clk_synchro_spectrum,
                i_detector_number         => i_detector_number,
                i_filter_number           => To_unsigned(N, Filter_Number_Width),
                -- entree depuis detect_standard_energy
                i_Energy_level_max        => energy_level_max_sd(N),
                i_readyEnergy_level_max   => ready_energy_level_max_sd(N),
                -- sortie vers FIFO PipeOut spectrum SD
                o_pipe_out_spectrum_din   => pipe_out_spectrum_sd_din(N),
                o_pipe_out_spectrum_wr_en => pipe_out_spectrum_sd_wr_en(N)
            );
    end generate generate_lable_spectrum_Standard_definition;

    o_pipe_out_spectrum_sd_din   <= pipe_out_spectrum_sd_din(0) when i_enable_high_filter = '0' else pipe_out_spectrum_sd_din(1);
    o_pipe_out_spectrum_sd_wr_en <= pipe_out_spectrum_sd_wr_en(0) when i_enable_high_filter = '0' else pipe_out_spectrum_sd_wr_en(1);

end architecture RTL;
