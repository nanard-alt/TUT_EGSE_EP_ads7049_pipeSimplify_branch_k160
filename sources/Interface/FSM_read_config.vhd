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

entity FSM_read_config is
    port(
        --global
        i_clk_slow              : in  std_logic;
        i_reset                 : in  std_logic;
        --input
        i_pipe_in_config_empty  : in  std_logic;
        i_pipe_in_config_valid  : in  std_logic;
        i_pipe_in_config_dout   : in  signed(31 downto 0);
        i_pipe_in_rd_data_count : in  STD_LOGIC_VECTOR(9 downto 0);
        --output
        o_pipe_in_config_rd_en  : out std_logic;
        o_coef_fir_ready        : out std_logic;
        o_coef_fir              : out Array_Array_config_32x16_type_32x16_type;
        --output reg 
        o_reg_config            : out Array_config_32stdx8_type;
        -- output gain
        o_gain                  : out Array_Array_config_32stdxDetector_Number_type
        -- output gain
        --o_gain_high_frequency   : out Array_Array_config_32stdx2_type
    );
end entity FSM_read_config;

architecture RTL of FSM_read_config is

    --    type state_type is (IDLE, read_low_frequency, valid_low_frequency, read_high_frequency, read_low_frequency, valid_low_frequency, read_trigger, valid_trigger);
    --    signal state    : state_type;
    constant Config_End_Padding_Word_Count : natural := 3;
    constant Config_Read_Word_Count        : natural := (32 * Filter_Number * Detector_Number) + 7 + (Filter_Number * Detector_Number) + Config_End_Padding_Word_Count;
    signal add_coef : integer;

    type state_type_config is (IDLE, read_low_frequency, valid_low_frequency, read_high_frequency, valid_high_frequency, read_trigger, valid_read_trigger,
                               read_TH_rise, valid_read_TH_rise, read_TL_fall, valid_read_TL_fall, read_TH_ADC, valid_read_TH_ADC, read_gain, valid_read_gain, read_gain_high_frequency,
                               valid_read_gain_high_frequency, read_level_DAC, valid_read_level_DAC, read_TH_rise_high_frequency, read_end_usb_buffer, valid_read_end_usb_buffer,
                               read_TH_fall_high_frequency, valid_read_TH_fall_high_frequency, valid_read_TH_rise_high_frequency,stop);

    signal state_config            : state_type_config;
    signal cnt_number_detector     : integer;
    signal cnt_read_end_usb_buffer : integer;
    signal count_wait_valid        : unsigned(5 downto 0);

begin

    ------------------------------------------------------------------------------------------------
    -- Raw buffer read
    ------------------------------------------------------------------------------------------------        

    read_config_FSM : process(i_clk_slow, i_reset) is
    begin
        if i_reset = '1' then

            state_config           <= IDLE;
            o_pipe_in_config_rd_en <= '0';
            add_coef               <= 0;
            o_coef_fir             <= (others => (others => (others => (others => '0'))));
            o_gain                 <= (others => (others => (others => '0')));


            --o_gain_high_frequency(0) <= (others => (others => '0'));
            --o_gain_high_frequency(1) <= (others => (others => '0'));
            o_coef_fir_ready        <= '0';
            cnt_number_detector     <= 0;
            cnt_read_end_usb_buffer <= 0;
            o_reg_config            <= (others => (others => '0'));
            count_wait_valid        <= (others => '0');

        elsif rising_edge(i_clk_slow) then

            case state_config is

                when IDLE =>

                    if i_pipe_in_config_empty = '0' and To_integer(unsigned(i_pipe_in_rd_data_count)) >= Config_Read_Word_Count then
                        state_config            <= read_low_frequency;
                        o_pipe_in_config_rd_en  <= '0';
                        add_coef                <= 0;
                        o_coef_fir              <= (others => (others => (others => (others => '0'))));
                        o_gain                  <= (others => (others => (others => '0')));
                       
                        --o_gain_high_frequency(0) <= (others => (others => '0'));
                        --o_gain_high_frequency(1) <= (others => (others => '0'));
                        o_coef_fir_ready        <= '0';
                        cnt_number_detector     <= 0;
                        cnt_read_end_usb_buffer <= 0;
                        o_reg_config            <= (others => (others => '0'));
                        count_wait_valid        <= (others => '0');
                    end if;

                when read_low_frequency =>

                    if add_coef < 32 then
                        o_pipe_in_config_rd_en <= '1';
                        state_config           <= valid_low_frequency;

                    else
                        cnt_number_detector <= cnt_number_detector + 1;

                        if cnt_number_detector = Detector_Number - 1 then
                            state_config           <= read_high_frequency;
                            o_pipe_in_config_rd_en <= '0';
                            --o_coef_fir_ready       <= '1';
                            add_coef               <= 0;
                            cnt_number_detector    <= 0;

                        else
                            state_config           <= read_low_frequency;
                            o_pipe_in_config_rd_en <= '0';
                            --o_coef_fir_ready       <= '1';
                            add_coef               <= 0;
                        end if;

                    end if;

                when valid_low_frequency =>

                    o_pipe_in_config_rd_en <= '0';

                    if i_pipe_in_config_valid = '1' then
                        o_coef_fir(cnt_number_detector)(0)(add_coef) <= i_pipe_in_config_dout(15 downto 0);
                        add_coef                                     <= add_coef + 1;
                        state_config                                 <= read_low_frequency;
                    end if;


                when read_high_frequency =>


                    if add_coef < 32 then
                        o_pipe_in_config_rd_en <= '1';
                        state_config           <= valid_high_frequency;

                    else
                        cnt_number_detector <= cnt_number_detector + 1;

                        if cnt_number_detector = Detector_Number - 1 then
                            state_config           <= read_trigger;
                            o_pipe_in_config_rd_en <= '0';
                            o_coef_fir_ready       <= '1';
                            add_coef               <= 0;
                            cnt_number_detector    <= 0;

                        else
                            state_config           <= read_high_frequency;
                            o_pipe_in_config_rd_en <= '0';
                            --o_coef_fir_ready       <= '1';
                            add_coef               <= 0;
                        end if;

                    end if;

                when valid_high_frequency =>
                
                    o_pipe_in_config_rd_en <= '0';
                
                    if i_pipe_in_config_valid = '1' then
                        o_coef_fir(cnt_number_detector)(1)(add_coef) <= i_pipe_in_config_dout(15 downto 0);
                        add_coef                                     <= add_coef + 1;
                        state_config                                 <= read_high_frequency;
                end if;


                when read_trigger =>

                    o_pipe_in_config_rd_en <= '1';
                    state_config           <= valid_read_trigger;

                when valid_read_trigger =>

                    o_pipe_in_config_rd_en <= '0';
                    if i_pipe_in_config_valid = '1' then
                        o_reg_config(1) <= std_logic_vector(i_pipe_in_config_dout);
                        state_config    <= read_TH_rise;
                    end if;

                when read_TH_rise =>

                    o_pipe_in_config_rd_en <= '1';
                    state_config           <= valid_read_TH_rise;

                when valid_read_TH_rise =>

                    o_pipe_in_config_rd_en <= '0';
                    if i_pipe_in_config_valid = '1' then
                        o_reg_config(2) <= std_logic_vector(i_pipe_in_config_dout);
                        state_config    <= read_TL_fall;
                    end if;

                when read_TL_fall =>

                    o_pipe_in_config_rd_en <= '1';
                    state_config           <= valid_read_TL_fall;

                when valid_read_TL_fall =>

                    o_pipe_in_config_rd_en <= '0';
                    if i_pipe_in_config_valid = '1' then
                        o_reg_config(3) <= std_logic_vector(i_pipe_in_config_dout);
                        state_config    <= read_TH_ADC;
                    end if;

                when read_TH_ADC =>

                    o_pipe_in_config_rd_en <= '1';
                    state_config           <= valid_read_TH_ADC;

                when valid_read_TH_ADC =>

                    o_pipe_in_config_rd_en <= '0';
                    if i_pipe_in_config_valid = '1' then
                        o_reg_config(4)     <= std_logic_vector(i_pipe_in_config_dout);
                        state_config        <= read_level_DAC;
                        cnt_number_detector <= 0;
                    end if;

                when read_level_DAC =>

                    o_pipe_in_config_rd_en <= '1';
                    state_config           <= valid_read_level_DAC;

                when valid_read_level_DAC =>

                    o_pipe_in_config_rd_en <= '0';
                    if i_pipe_in_config_valid = '1' then
                        o_reg_config(5)     <= std_logic_vector(i_pipe_in_config_dout);
                        state_config        <= read_TH_rise_high_frequency;
                        cnt_number_detector <= 0;
                    end if;

                when read_TH_rise_high_frequency =>

                    o_pipe_in_config_rd_en <= '1';
                    state_config           <= valid_read_TH_rise_high_frequency;

                when valid_read_TH_rise_high_frequency =>

                    o_pipe_in_config_rd_en <= '0';
                    if i_pipe_in_config_valid = '1' then
                        o_reg_config(6)     <= std_logic_vector(i_pipe_in_config_dout);
                        state_config        <= read_TH_fall_high_frequency;
                        cnt_number_detector <= 0;
                    end if;

                when read_TH_fall_high_frequency =>

                    o_pipe_in_config_rd_en <= '1';
                    state_config           <= valid_read_TH_fall_high_frequency;

                when valid_read_TH_fall_high_frequency =>

                    o_pipe_in_config_rd_en <= '0';
                    if i_pipe_in_config_valid = '1' then
                        o_reg_config(7)     <= std_logic_vector(i_pipe_in_config_dout);
                        state_config        <= read_gain;
                        cnt_number_detector <= 0;
                    end if;

                --------------------------------------------------------------------------------------------------
                when read_gain =>

                    if cnt_number_detector = Detector_Number then
                        state_config           <= read_gain_high_frequency;
                        o_pipe_in_config_rd_en <= '0';
                        cnt_number_detector    <= 0;

                    else
                        state_config           <= valid_read_gain;
                        o_pipe_in_config_rd_en <= '1';
                        --o_coef_fir_ready       <= '1';

                    end if;

                when valid_read_gain =>

                    o_pipe_in_config_rd_en <= '0';

                    if i_pipe_in_config_valid = '1' then
                        cnt_number_detector            <= cnt_number_detector + 1;
                        o_gain(cnt_number_detector)(0) <= unsigned(i_pipe_in_config_dout); -- set all detector for low frequency filter
                        state_config                   <= read_gain;
                    end if;

                when read_gain_high_frequency =>

                    if cnt_number_detector = Detector_Number then
                        state_config           <= read_end_usb_buffer;
                        o_pipe_in_config_rd_en <= '0';
                        cnt_number_detector    <= 0;

                    else
                        state_config           <= valid_read_gain_high_frequency;
                        o_pipe_in_config_rd_en <= '1';
                        --o_coef_fir_ready       <= '1';

                    end if;

                when valid_read_gain_high_frequency =>

                    o_pipe_in_config_rd_en <= '0';

                    if i_pipe_in_config_valid = '1' then
                        cnt_number_detector            <= cnt_number_detector + 1;
                        o_gain(cnt_number_detector)(1) <= unsigned(i_pipe_in_config_dout); -- set all detector high_frequency
                        state_config                   <= read_gain_high_frequency;
                    end if;

                when read_end_usb_buffer =>

                    if cnt_read_end_usb_buffer = Config_End_Padding_Word_Count then
                        state_config           <= IDLE;
                        o_pipe_in_config_rd_en <= '0';
                        cnt_number_detector    <= 0;

                        cnt_number_detector <= 0;
                    else
                        state_config           <= valid_read_end_usb_buffer;
                        o_pipe_in_config_rd_en <= '1';
                        --o_coef_fir_ready       <= '1';

                    end if;

                when valid_read_end_usb_buffer =>

                    o_pipe_in_config_rd_en <= '0';

                    count_wait_valid <= count_wait_valid + 1;

                    if i_pipe_in_config_valid = '1' then
                        cnt_read_end_usb_buffer <= cnt_read_end_usb_buffer + 1;
                        state_config            <= read_end_usb_buffer;

                        if count_wait_valid = 3 then
                            o_pipe_in_config_rd_en <= '0';
                            state_config           <= IDLE;
                            cnt_number_detector    <= 0;

                        else
                            o_pipe_in_config_rd_en <= '0';

                        end if;

                    end if;

                when others =>

            end case;

        end if;
    end process;

end architecture RTL;
