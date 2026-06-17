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

entity FIR_filter is
    port(
        --global
        i_clk_slow       : in  std_logic;
        i_reset          : in  std_logic;
        --input
        i_coef_fir       : in  Array_config_32x16_type;
        i_coef_fir_ready : in  std_logic;
        i_data           : in  signed(15 downto 0);
        i_ready          : in  std_logic;
        --output
        o_data           : out signed(15 downto 0);
        o_ready          : out std_logic
    );
end entity FIR_filter;

architecture RTL of FIR_filter is

    constant coef0  : signed(15 downto 0) := x"ffff";
    constant coef1  : signed(15 downto 0) := x"fffe";
    constant coef2  : signed(15 downto 0) := x"fffe";
    constant coef3  : signed(15 downto 0) := x"fffd";
    constant coef4  : signed(15 downto 0) := x"fffc";
    constant coef5  : signed(15 downto 0) := x"fffa";
    constant coef6  : signed(15 downto 0) := x"fff8";
    constant coef7  : signed(15 downto 0) := x"fff5";
    constant coef8  : signed(15 downto 0) := x"fff1";
    constant coef9  : signed(15 downto 0) := x"ffec";
    constant coef10 : signed(15 downto 0) := x"ffe5";
    constant coef11 : signed(15 downto 0) := x"ffdc";
    constant coef12 : signed(15 downto 0) := x"ffd0";
    constant coef13 : signed(15 downto 0) := x"ffc0";
    constant coef14 : signed(15 downto 0) := x"ffab";
    constant coef15 : signed(15 downto 0) := x"ff8e";
    constant coef16 : signed(15 downto 0) := x"ff68";
    constant coef17 : signed(15 downto 0) := x"ff36";
    constant coef18 : signed(15 downto 0) := x"fef2";
    constant coef19 : signed(15 downto 0) := x"fe99";
    constant coef20 : signed(15 downto 0) := x"fe22";
    constant coef21 : signed(15 downto 0) := x"fd85";
    constant coef22 : signed(15 downto 0) := x"fcb8";
    constant coef23 : signed(15 downto 0) := x"fbae";
    constant coef24 : signed(15 downto 0) := x"fa5e";
    constant coef25 : signed(15 downto 0) := x"f8c7";
    constant coef26 : signed(15 downto 0) := x"f70a";
    constant coef27 : signed(15 downto 0) := x"f595";
    constant coef28 : signed(15 downto 0) := x"f59b";
    constant coef29 : signed(15 downto 0) := x"fa21";
    constant coef30 : signed(15 downto 0) := x"0a6e";
    constant coef31 : signed(15 downto 0) := x"37a6";

    signal data0  : signed(15 downto 0);
    signal data1  : signed(15 downto 0);
    signal data2  : signed(15 downto 0);
    signal data3  : signed(15 downto 0);
    signal data4  : signed(15 downto 0);
    signal data5  : signed(15 downto 0);
    signal data6  : signed(15 downto 0);
    signal data7  : signed(15 downto 0);
    signal data8  : signed(15 downto 0);
    signal data9  : signed(15 downto 0);
    signal data10 : signed(15 downto 0);
    signal data11 : signed(15 downto 0);
    signal data12 : signed(15 downto 0);
    signal data13 : signed(15 downto 0);
    signal data14 : signed(15 downto 0);
    signal data15 : signed(15 downto 0);
    signal data16 : signed(15 downto 0);
    signal data17 : signed(15 downto 0);
    signal data18 : signed(15 downto 0);
    signal data19 : signed(15 downto 0);
    signal data20 : signed(15 downto 0);
    signal data21 : signed(15 downto 0);
    signal data22 : signed(15 downto 0);
    signal data23 : signed(15 downto 0);
    signal data24 : signed(15 downto 0);
    signal data25 : signed(15 downto 0);
    signal data26 : signed(15 downto 0);
    signal data27 : signed(15 downto 0);
    signal data28 : signed(15 downto 0);
    signal data29 : signed(15 downto 0);
    signal data30 : signed(15 downto 0);
    signal data31 : signed(15 downto 0);

    signal data0_out_mult  : signed(31 downto 0);
    signal data1_out_mult  : signed(31 downto 0);
    signal data2_out_mult  : signed(31 downto 0);
    signal data3_out_mult  : signed(31 downto 0);
    signal data4_out_mult  : signed(31 downto 0);
    signal data5_out_mult  : signed(31 downto 0);
    signal data6_out_mult  : signed(31 downto 0);
    signal data7_out_mult  : signed(31 downto 0);
    signal data8_out_mult  : signed(31 downto 0);
    signal data9_out_mult  : signed(31 downto 0);
    signal data10_out_mult : signed(31 downto 0);
    signal data11_out_mult : signed(31 downto 0);
    signal data12_out_mult : signed(31 downto 0);
    signal data13_out_mult : signed(31 downto 0);
    signal data14_out_mult : signed(31 downto 0);
    signal data15_out_mult : signed(31 downto 0);
    signal data16_out_mult : signed(31 downto 0);
    signal data17_out_mult : signed(31 downto 0);
    signal data18_out_mult : signed(31 downto 0);
    signal data19_out_mult : signed(31 downto 0);
    signal data20_out_mult : signed(31 downto 0);
    signal data21_out_mult : signed(31 downto 0);
    signal data22_out_mult : signed(31 downto 0);
    signal data23_out_mult : signed(31 downto 0);
    signal data24_out_mult : signed(31 downto 0);
    signal data25_out_mult : signed(31 downto 0);
    signal data26_out_mult : signed(31 downto 0);
    signal data27_out_mult : signed(31 downto 0);
    signal data28_out_mult : signed(31 downto 0);
    signal data29_out_mult : signed(31 downto 0);
    signal data30_out_mult : signed(31 downto 0);
    signal data31_out_mult : signed(31 downto 0);

    --signal sum               : signed(16 downto 0);
    signal enable_FIR_filter : std_logic;
    signal count             : unsigned(17 downto 0);
    signal count_inter_ready : unsigned(17 downto 0);
    signal init_FIR_filter   : std_logic;

begin

    -------------------------------------------------------------------
    -- Flip flop trunk
    -------------------------------------------------------------------

    process(i_clk_slow) is
    begin
        if rising_edge(i_clk_slow) then
            if i_reset = '1' then
                data0  <= (others => '0');
                data1  <= (others => '0');
                data2  <= (others => '0');
                data3  <= (others => '0');
                data4  <= (others => '0');
                data5  <= (others => '0');
                data6  <= (others => '0');
                data7  <= (others => '0');
                data8  <= (others => '0');
                data9  <= (others => '0');
                data10 <= (others => '0');
                data11 <= (others => '0');
                data12 <= (others => '0');
                data13 <= (others => '0');
                data14 <= (others => '0');
                data15 <= (others => '0');
                data16 <= (others => '0');
                data17 <= (others => '0');
                data18 <= (others => '0');
                data19 <= (others => '0');
                data20 <= (others => '0');
                data21 <= (others => '0');
                data22 <= (others => '0');
                data23 <= (others => '0');
                data24 <= (others => '0');
                data25 <= (others => '0');
                data26 <= (others => '0');
                data27 <= (others => '0');
                data28 <= (others => '0');
                data29 <= (others => '0');
                data30 <= (others => '0');
                data31 <= (others => '0');

            elsif i_ready = '1' and i_coef_fir_ready = '1' then
                data0  <= i_data;
                data1  <= data0;
                data2  <= data1;
                data3  <= data2;
                data4  <= data3;
                data5  <= data4;
                data6  <= data5;
                data7  <= data6;
                data8  <= data7;
                data9  <= data8;
                data10 <= data9;
                data11 <= data10;
                data12 <= data11;
                data13 <= data12;
                data14 <= data13;
                data15 <= data14;
                data16 <= data15;
                data17 <= data16;

                data18 <= data17;
                data19 <= data18;
                data20 <= data19;
                data21 <= data20;
                data22 <= data21;
                data23 <= data22;
                data24 <= data23;
                data25 <= data24;
                data26 <= data25;
                data27 <= data26;
                data28 <= data27;
                data29 <= data28;
                data30 <= data29;
                data31 <= data30;
            end if;
        end if;
    end process;

    -------------------------------------------------------------------
    -- Mult
    -------------------------------------------------------------------

    process(i_clk_slow) is
    begin
        if rising_edge(i_clk_slow) then
            if i_reset = '1' then
                data0_out_mult  <= (others => '0');
                data1_out_mult  <= (others => '0');
                data2_out_mult  <= (others => '0');
                data3_out_mult  <= (others => '0');
                data4_out_mult  <= (others => '0');
                data5_out_mult  <= (others => '0');
                data6_out_mult  <= (others => '0');
                data7_out_mult  <= (others => '0');
                data8_out_mult  <= (others => '0');
                data9_out_mult  <= (others => '0');
                data10_out_mult <= (others => '0');
                data11_out_mult <= (others => '0');
                data12_out_mult <= (others => '0');
                data13_out_mult <= (others => '0');
                data14_out_mult <= (others => '0');
                data15_out_mult <= (others => '0');
                data16_out_mult <= (others => '0');
                data17_out_mult <= (others => '0');
                data18_out_mult <= (others => '0');
                data19_out_mult <= (others => '0');
                data20_out_mult <= (others => '0');
                data21_out_mult <= (others => '0');
                data22_out_mult <= (others => '0');
                data23_out_mult <= (others => '0');
                data24_out_mult <= (others => '0');
                data25_out_mult <= (others => '0');
                data26_out_mult <= (others => '0');
                data27_out_mult <= (others => '0');
                data28_out_mult <= (others => '0');
                data29_out_mult <= (others => '0');
                data30_out_mult <= (others => '0');
                data31_out_mult <= (others => '0');

            elsif i_ready = '1' and i_coef_fir_ready = '1' then
                data0_out_mult  <= i_coef_fir(31) * data0;
                data1_out_mult  <= i_coef_fir(30) * data1;
                data2_out_mult  <= i_coef_fir(29) * data2;
                data3_out_mult  <= i_coef_fir(28) * data3;
                data4_out_mult  <= i_coef_fir(27) * data4;
                data5_out_mult  <= i_coef_fir(26) * data5;
                data6_out_mult  <= i_coef_fir(25) * data6;
                data7_out_mult  <= i_coef_fir(24) * data7;
                data8_out_mult  <= i_coef_fir(23) * data8;
                data9_out_mult  <= i_coef_fir(22) * data9;
                data10_out_mult <= i_coef_fir(21) * data10;
                data11_out_mult <= i_coef_fir(20) * data11;
                data12_out_mult <= i_coef_fir(19) * data12;
                data13_out_mult <= i_coef_fir(18) * data13;
                data14_out_mult <= i_coef_fir(17) * data14;
                data15_out_mult <= i_coef_fir(16) * data15;
                data16_out_mult <= i_coef_fir(15) * data16;
                data17_out_mult <= i_coef_fir(14) * data17;
                data18_out_mult <= i_coef_fir(13) * data18;
                data19_out_mult <= i_coef_fir(12) * data19;
                data20_out_mult <= i_coef_fir(11) * data20;
                data21_out_mult <= i_coef_fir(10) * data21;
                data22_out_mult <= i_coef_fir(9) * data22;
                data23_out_mult <= i_coef_fir(8) * data23;
                data24_out_mult <= i_coef_fir(7) * data24;
                data25_out_mult <= i_coef_fir(6) * data25;
                data26_out_mult <= i_coef_fir(5) * data26;
                data27_out_mult <= i_coef_fir(4) * data27;
                data28_out_mult <= i_coef_fir(3) * data28;
                data29_out_mult <= i_coef_fir(2) * data29;
                data30_out_mult <= i_coef_fir(1) * data30;
                data31_out_mult <= i_coef_fir(0) * data31;
            end if;
        end if;
    end process;

    -------------------------------------------------------------------
    -- SUM
    -------------------------------------------------------------------

    process(i_clk_slow) is
    begin
        if rising_edge(i_clk_slow) then
            if i_reset = '1' then
                o_data  <= (others => '0');
                o_ready <= '0';

            elsif i_ready = '1' and i_coef_fir_ready = '1' then
                --if i_ready = '1' and i_coef_fir_ready = '1' and init_FIR_filter = '1' then
                o_data  <= (data0_out_mult(31 downto 16)) + (data1_out_mult(31 downto 16)) + (data2_out_mult(31 downto 16)) + (data3_out_mult(31 downto 16)) + (data4_out_mult(31 downto 16)) + (data5_out_mult(31 downto 16)) + (data6_out_mult(31 downto 16)) + (data7_out_mult(31 downto 16)) + (data8_out_mult(31 downto 16)) + (data9_out_mult(31 downto 16)) + (data10_out_mult(31 downto 16)) + (data11_out_mult(31 downto 16)) + (data12_out_mult(31 downto 16)) + (data13_out_mult(31 downto 16)) + (data14_out_mult(31 downto 16)) + (data15_out_mult(31 downto 16)) + (data16_out_mult(31 downto 16)) + (data17_out_mult(31 downto 16)) + (data18_out_mult(31 downto 16)) + (data19_out_mult(31 downto 16)) + (data20_out_mult(31 downto 16)) + (data21_out_mult(31 downto 16)) + (data22_out_mult(31 downto 16)) + (data23_out_mult(31 downto 16)) + (data24_out_mult(31 downto 16)) + (data25_out_mult(31 downto 16)) + (data26_out_mult(31 downto 16)) + (data27_out_mult(31 downto 16)) + (data28_out_mult(31 downto 16)) + (data29_out_mult(31 downto 16)) + (data30_out_mult(31 downto 16)) + (data31_out_mult(31 downto 16));
                o_ready <= i_ready;
            else
                o_ready <= '0';
            end if;
        end if;
    end process;

    --o_data <= sum(16 downto 1);

    -------------------------------------------------------------------
    -- unlock FIR filter
    -------------------------------------------------------------------
    process(i_clk_slow) is
    begin
        if rising_edge(i_clk_slow) then
            if i_reset = '1' then
                null;
            elsif data31_out_mult /= 0 then

                --enable_FIR_filter <= '1';

            end if;

        end if;
    end process;

    -------------------------------------------------------------------
    -- unlock FIR filter
    -------------------------------------------------------------------
    process(i_clk_slow) is
    begin
        if rising_edge(i_clk_slow) then
            if i_reset = '1' then
                init_FIR_filter <= '0';
                count           <= (others => '0');
            elsif i_ready = '1' and i_coef_fir_ready = '1' then
                count <= count + 1;
                if To_integer(count) = (32) then
                    init_FIR_filter <= '1';
                end if;
            end if;
        end if;
    end process;

    -------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------
    process(i_clk_slow) is
    begin
        if rising_edge(i_clk_slow) then
            if i_reset = '1' then
                count_inter_ready <= (others => '0');
            else
                count_inter_ready <= count_inter_ready + 1;

                if i_ready = '1' then
                    count_inter_ready <= (others => '0');
                end if;

            end if;
        end if;
    end process;

end architecture RTL;
