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

entity fifo_sync is
    generic (
        DATA_WIDTH : positive := 32;
        DEPTH      : positive := 8192;
        ADDR_WIDTH : positive := 13
    );
    port (
        i_clk   : in  std_logic;
        i_reset : in  std_logic;

        i_wr_en : in  std_logic;
        i_din   : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        o_full  : out std_logic;

        i_rd_en : in  std_logic;
        o_dout  : out std_logic_vector(DATA_WIDTH - 1 downto 0);
        o_empty : out std_logic
    );
end entity fifo_sync;

architecture RTL of fifo_sync is

    subtype addr_type is unsigned(ADDR_WIDTH - 1 downto 0);
    type ram_type is array (0 to DEPTH - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);

    signal ram      : ram_type;
    signal wr_addr  : addr_type;
    signal rd_addr  : addr_type;
    signal count    : unsigned(ADDR_WIDTH downto 0);
    signal dout_reg : std_logic_vector(DATA_WIDTH - 1 downto 0);

begin

    fifo_process : process(i_clk, i_reset) is
    begin
        if i_reset = '1' then
            wr_addr  <= (others => '0');
            rd_addr  <= (others => '0');
            count    <= (others => '0');
            dout_reg <= (others => '0');

        elsif rising_edge(i_clk) then
            if (i_wr_en = '1') and ((count < to_unsigned(DEPTH, count'length)) or ((i_rd_en = '1') and (count > 0))) then
                ram(to_integer(wr_addr)) <= i_din;
                if wr_addr = to_unsigned(DEPTH - 1, wr_addr'length) then
                    wr_addr <= (others => '0');
                else
                    wr_addr <= wr_addr + 1;
                end if;
            end if;

            if (i_rd_en = '1') and (count > 0) then
                dout_reg <= ram(to_integer(rd_addr));
                if rd_addr = to_unsigned(DEPTH - 1, rd_addr'length) then
                    rd_addr <= (others => '0');
                else
                    rd_addr <= rd_addr + 1;
                end if;
            end if;

            if ((i_wr_en = '1') and (count < to_unsigned(DEPTH, count'length))) and not ((i_rd_en = '1') and (count > 0)) then
                count <= count + 1;
            elsif ((i_rd_en = '1') and (count > 0)) and not ((i_wr_en = '1') and ((count < to_unsigned(DEPTH, count'length)) or ((i_rd_en = '1') and (count > 0)))) then
                count <= count - 1;
            end if;
        end if;
    end process fifo_process;

    o_dout  <= dout_reg;
    o_full  <= '1' when count = to_unsigned(DEPTH, count'length) else '0';
    o_empty <= '1' when count = 0 else '0';

end architecture RTL;
