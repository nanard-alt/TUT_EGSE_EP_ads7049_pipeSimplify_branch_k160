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

entity spectrum_FSM is

    generic(
        memory_add_size : integer := 10;
        depth_memory    : integer := 1024
    );

    port(
        -- global
        i_clk_slow                : in  std_logic;
        i_reset                   : in  std_logic;
        i_filter_number           : in  unsigned;
        -- synchro_spectrum
        i_clk_synchro_spectrum    : in  std_logic;
        i_detector_number         : in  unsigned;
        i_set_synchro_spectrum    : in  std_logic_vector(0 downto 0);
        -- RAM
        o_we                      : out std_logic;
        o_en                      : out std_logic;
        o_addr                    : out std_logic_vector(memory_add_size - 1 downto 0);
        o_di                      : out std_logic_vector(15 downto 0);
        i_do                      : in  std_logic_vector(15 downto 0);
        -- input from detect Energy level
        i_ready_energy_level_max  : in  std_logic;
        i_energy_level_max        : in  signed(15 downto 0);
        -- out spectrum to fifo pipe out
        o_pipe_out_spectrum_din   : out std_logic_vector(31 downto 0);
        o_pipe_out_spectrum_wr_en : out std_logic;
        o_spectrum_count_pulse    : out std_logic_vector(31 downto 0)
    );
end entity spectrum_FSM;

architecture RTL of spectrum_FSM is

    type state_type is (init_ram, detect_energy_max_ready, read_ram, write_ram, wait_send_header, header_to_gse, first_data_to_gse, write_to_gse, last_data_to_gse, end_write_to_gse, init_ram_work, dispatch);
    signal TM_Byte_index        : integer range 0 to 8;
    signal state                : state_type;
    signal addr                 : unsigned(memory_add_size - 1 downto 0);
    signal old_addr             : unsigned(memory_add_size - 1 downto 0);
    signal spectrum_count_pulse : std_logic_vector(31 downto 0);
    signal clk_synchro_spectrum : std_logic;
    signal init_count_synchro_spectrum : unsigned(26 downto 0);


begin

    process(i_clk_slow, i_reset) is
    begin
        if i_reset = '1' then

            state                     <= init_ram;
            o_we                      <= '1';
            o_en                      <= '1';
            addr                      <= (others => '1');
            old_addr                  <= (others => '0');
            o_di                      <= (others => '0');
            o_pipe_out_spectrum_din   <= (others => '0');
            o_pipe_out_spectrum_wr_en <= '0';
            spectrum_count_pulse      <= (others => '0');
            o_spectrum_count_pulse    <= (others => '0');
            TM_Byte_index             <= 0;
            clk_synchro_spectrum      <= '0';
            init_count_synchro_spectrum <= (others => '0');

        elsif rising_edge(i_clk_slow) then

            clk_synchro_spectrum <= i_clk_synchro_spectrum;

            case state is

                when init_ram =>

                    if To_integer(unsigned(addr)) = 0 then
                        addr  <= To_unsigned(0, memory_add_size);
                        state <= detect_energy_max_ready;
                        o_we  <= '0';
                        o_en  <= '0';
                    else
                        o_di <= (others => '0');
                        addr <= (addr) - 1;
                        o_we <= '1';
                        o_en <= '1';

                    end if;

                when detect_energy_max_ready =>

                    o_en <= '0';
                    o_we <= '0';

                    if clk_synchro_spectrum = i_set_synchro_spectrum(0) then
                        state         <= wait_send_header;
                        TM_Byte_index <= 0;
                        addr          <= (others => '0');
                        old_addr      <= (others => '0');
                        o_en          <= '0';
                        o_we          <= '0';

                    else
                        if i_ready_energy_level_max = '1' then
                            spectrum_count_pulse <= std_logic_vector(unsigned(spectrum_count_pulse) + 1);
                            addr                 <= unsigned(i_energy_level_max(i_energy_level_max'left - 1 downto i_energy_level_max'left - memory_add_size)); -- remove MSB(15) sign bit always 0
                            o_en                 <= '1';
                            state                <= read_ram;
                        end if;
                    end if;

                when read_ram =>

                    o_en  <= '0';
                    o_we  <= '0';
                    state <= write_ram;

                when write_ram =>

                    o_en  <= '1';
                    o_we  <= '1';
                    o_di  <= std_logic_vector(unsigned(i_do) + 1);
                    state <= detect_energy_max_ready;

                when wait_send_header =>

                    init_count_synchro_spectrum <= init_count_synchro_spectrum + 1;
                    if To_integer(init_count_synchro_spectrum) >= (2056 * To_integer(i_detector_number)) then
                        state <= header_to_gse;
                        init_count_synchro_spectrum <= (others => '0');
                    end if;

                when header_to_gse =>

                    TM_Byte_index <= TM_Byte_index + 1;

                    case TM_Byte_index is

                        when 0 =>       -- write ID
                            o_pipe_out_spectrum_wr_en <= '1';
                            o_pipe_out_spectrum_din   <= "1000" & "0" & std_logic_vector(i_detector_number) & std_logic_vector(i_filter_number) & x"0000" & "0000000" & i_set_synchro_spectrum;

                            o_spectrum_count_pulse <= spectrum_count_pulse;
                        --------------------------------------------------------
                        when 1 =>       -- write TimeMSB
                            o_pipe_out_spectrum_din <= x"AAAAAAAA";
                        --------------------------------------------------------
                        when 2 =>       -- write T
                            o_pipe_out_spectrum_din <= x"10000000";
                        --------------------------------------------------------
                        when 3 =>       -- write TimeLSB
                            o_pipe_out_spectrum_din <= x"A5555555";
                        --------------------------------------------------------
                        when 4 to 5 =>
                            state                     <= first_data_to_gse;
                            o_pipe_out_spectrum_wr_en <= '0';
                            o_en                      <= '1';
                            TM_Byte_index             <= 0;
                        --------------------------------------------------------
                        when others =>

                    end case;

                when first_data_to_gse =>

                    addr     <= addr + 1;
                    old_addr <= addr;
                    state    <= write_to_gse;

                when write_to_gse =>

                    addr     <= addr + 1;
                    old_addr <= addr;

                    o_pipe_out_spectrum_wr_en <= '1';
                    o_pipe_out_spectrum_din   <= std_logic_vector(resize(old_addr, 16)) & i_do;

                    if To_integer(unsigned(addr)) = (depth_memory - 1) then
                        o_en  <= '0';
                        state <= last_data_to_gse;
                    end if;

                when last_data_to_gse =>
                    o_pipe_out_spectrum_din <= std_logic_vector(resize(old_addr, 16)) & i_do;
                    state                   <= end_write_to_gse;

                when end_write_to_gse =>

                    o_pipe_out_spectrum_wr_en <= '0';
                    state                     <= init_ram_work;
                    o_we                      <= '1';
                    o_en                      <= '1';
                    addr                      <= (others => '1');
                    o_di                      <= (others => '0');

                when init_ram_work =>

                    if To_integer(unsigned(addr)) = 0 then
                        addr  <= To_unsigned(0, memory_add_size);
                        state <= dispatch;
                        o_we  <= '0';
                        o_en  <= '0';
                    else
                        o_di <= (others => '0');
                        addr <= (addr) - 1;
                        o_we <= '1';
                        o_en <= '1';

                    end if;

                when dispatch =>

                    o_pipe_out_spectrum_wr_en <= '0';

                    if i_clk_synchro_spectrum = not (i_set_synchro_spectrum(0)) then

                        state <= detect_energy_max_ready;

                    end if;

            end case;
        end if;
    end process;

    o_addr <= std_logic_vector(addr);

end architecture RTL;
