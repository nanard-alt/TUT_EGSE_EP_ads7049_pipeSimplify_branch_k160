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

entity spectrum_serializer is
    port (
        i_clk   : in  std_logic;
        i_reset : in  std_logic;

        i_spectrum_dout  : in  std_logic_vector(31 downto 0);
        i_spectrum_empty : in  std_logic;
        o_spectrum_rd_en : out std_logic;

        i_spectrum_sd_dout  : in  std_logic_vector(31 downto 0);
        i_spectrum_sd_empty : in  std_logic;
        o_spectrum_sd_rd_en : out std_logic;

        o_spectrum_bit   : out std_logic;
        o_spectrum_wr_en : out std_logic;
        o_spectrum_clk   : out std_logic;
        o_spectrum_sof   : out std_logic;

        o_spectrum_sd_bit   : out std_logic;
        o_spectrum_sd_wr_en : out std_logic;
        o_spectrum_sd_clk   : out std_logic;
        o_spectrum_sd_sof   : out std_logic
    );
end entity spectrum_serializer;

architecture RTL of spectrum_serializer is

    type serial_state_type is (IDLE, LOAD, SHIFT);

    signal spectrum_state     : serial_state_type;
    signal spectrum_shift_reg : std_logic_vector(31 downto 0);
    signal spectrum_bit_count : unsigned(5 downto 0);
    signal spectrum_bit       : std_logic;
    signal spectrum_wr_en     : std_logic;
    signal spectrum_sof       : std_logic;
    signal spectrum_rd_en     : std_logic;

    signal spectrum_sd_state     : serial_state_type;
    signal spectrum_sd_shift_reg : std_logic_vector(31 downto 0);
    signal spectrum_sd_bit_count : unsigned(5 downto 0);
    signal spectrum_sd_bit       : std_logic;
    signal spectrum_sd_wr_en     : std_logic;
    signal spectrum_sd_sof       : std_logic;
    signal spectrum_sd_rd_en     : std_logic;

begin

    serialize_spectrum : process(i_clk, i_reset) is
    begin
        if i_reset = '0' then
            spectrum_state     <= IDLE;
            spectrum_shift_reg <= (others => '0');
            spectrum_bit_count <= (others => '0');
            spectrum_bit       <= '0';
            spectrum_wr_en     <= '0';
            spectrum_sof       <= '0';
            spectrum_rd_en     <= '0';

        elsif rising_edge(i_clk) then
            spectrum_wr_en <= '0';
            spectrum_sof   <= '0';
            spectrum_rd_en <= '0';

            case spectrum_state is
                when IDLE =>
                    if i_spectrum_empty = '0' then
                        spectrum_rd_en <= '1';
                        spectrum_state <= LOAD;
                    end if;

                when LOAD =>
                    spectrum_shift_reg <= i_spectrum_dout;
                    spectrum_bit_count <= to_unsigned(31, spectrum_bit_count'length);
                    spectrum_state     <= SHIFT;

                when SHIFT =>
                    spectrum_bit   <= spectrum_shift_reg(31);
                    spectrum_wr_en <= '1';
                    if spectrum_bit_count = to_unsigned(31, spectrum_bit_count'length) then
                        spectrum_sof <= '1';
                    end if;

                    spectrum_shift_reg <= spectrum_shift_reg(30 downto 0) & '0';

                    if spectrum_bit_count = 0 then
                        spectrum_state <= IDLE;
                    else
                        spectrum_bit_count <= spectrum_bit_count - 1;
                    end if;
            end case;
        end if;
    end process serialize_spectrum;

    serialize_spectrum_sd : process(i_clk, i_reset) is
    begin
        if i_reset = '0' then
            spectrum_sd_state     <= IDLE;
            spectrum_sd_shift_reg <= (others => '0');
            spectrum_sd_bit_count <= (others => '0');
            spectrum_sd_bit       <= '0';
            spectrum_sd_wr_en     <= '0';
            spectrum_sd_sof       <= '0';
            spectrum_sd_rd_en     <= '0';

        elsif rising_edge(i_clk) then
            spectrum_sd_wr_en <= '0';
            spectrum_sd_sof   <= '0';
            spectrum_sd_rd_en <= '0';

            case spectrum_sd_state is
                when IDLE =>
                    if i_spectrum_sd_empty = '0' then
                        spectrum_sd_rd_en <= '1';
                        spectrum_sd_state <= LOAD;
                    end if;

                when LOAD =>
                    spectrum_sd_shift_reg <= i_spectrum_sd_dout;
                    spectrum_sd_bit_count <= to_unsigned(31, spectrum_sd_bit_count'length);
                    spectrum_sd_state     <= SHIFT;

                when SHIFT =>
                    spectrum_sd_bit   <= spectrum_sd_shift_reg(31);
                    spectrum_sd_wr_en <= '1';
                    if spectrum_sd_bit_count = to_unsigned(31, spectrum_sd_bit_count'length) then
                        spectrum_sd_sof <= '1';
                    end if;

                    spectrum_sd_shift_reg <= spectrum_sd_shift_reg(30 downto 0) & '0';

                    if spectrum_sd_bit_count = 0 then
                        spectrum_sd_state <= IDLE;
                    else
                        spectrum_sd_bit_count <= spectrum_sd_bit_count - 1;
                    end if;
            end case;
        end if;
    end process serialize_spectrum_sd;

    o_spectrum_rd_en <= spectrum_rd_en;
    o_spectrum_bit   <= spectrum_bit;
    o_spectrum_wr_en <= spectrum_wr_en;
    o_spectrum_clk   <= i_clk;
    o_spectrum_sof   <= spectrum_sof;

    o_spectrum_sd_rd_en <= spectrum_sd_rd_en;
    o_spectrum_sd_bit   <= spectrum_sd_bit;
    o_spectrum_sd_wr_en <= spectrum_sd_wr_en;
    o_spectrum_sd_clk   <= i_clk;
    o_spectrum_sd_sof   <= spectrum_sd_sof;

end architecture RTL;
