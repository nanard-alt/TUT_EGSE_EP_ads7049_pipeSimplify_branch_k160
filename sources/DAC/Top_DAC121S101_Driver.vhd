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

entity Top_DAC121S101_Driver is
    port(
        -- Reset and clock
        i_reset         : in  std_logic;
        i_clk           : in  std_logic;
        -- DAC setting
        i_level_DAC121S : in  std_logic_vector(31 downto 0);
        -- DAC outputs
        o_DAC_SCLK      : out std_logic;
        o_DAC_SYNC_n    : out std_logic;
        o_DAC_DIN       : out std_logic;
        o_DAC_on_off    : out std_logic
    );
end entity Top_DAC121S101_Driver;

architecture RTL of Top_DAC121S101_Driver is

    signal Start    : std_logic;
    signal Busy     : std_logic;
    signal Num_Data : std_logic_vector(11 downto 0);

    signal Rst_n : std_logic;

begin

    Rst_n <= not i_reset;

    label_DAC121S101_Driver : entity work.DAC121S101_Driver
        port map(
            i_Rst_n      => Rst_n,
            i_Clk        => i_clk,
            i_Start      => Start,
            o_Busy       => Busy,
            i_Num_Data   => Num_Data,
            o_DAC_SCLK   => o_DAC_SCLK,
            o_DAC_SYNC_n => o_DAC_SYNC_n,
            o_DAC_DIN    => o_DAC_DIN
        );

    label_remote_DAC121S101_Driver : entity work.remote_DAC121S01_driver
        port map(
            i_Rst_n       => Rst_n,
            i_Clk         => i_clk,
            o_Start       => Start,
            i_Busy        => Busy,
            o_Num_Data    => Num_Data,
            level_DAC121S => i_level_DAC121S
        );

    o_DAC_on_off <= Num_Data(0);

end architecture RTL;
