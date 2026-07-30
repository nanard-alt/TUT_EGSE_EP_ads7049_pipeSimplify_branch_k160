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

entity gain is
    port(
        -- global
        i_clk_slow           : in  std_logic; -- horloge systeme lente
        i_reset              : in  std_logic; -- reset actif a 1

        -- configuration du gain
        i_gain               : in  unsigned(15 downto 0); -- gain applique sous forme de decalage 2^i_gain

        -- entree echantillon filtre provenant de FIR_filter
        i_data_after_filter  : in  signed(15 downto 0); -- echantillon apres filtrage FIR
        i_ready_after_filter : in  std_logic; -- pulse indiquant que i_data_after_filter est valide

        -- sortie echantillon amplifie vers Energy_level
        o_data_after_gain    : out signed(15 downto 0); -- echantillon apres application du gain
        o_ready_after_gain   : out std_logic -- pulse indiquant que o_data_after_gain est valide
    );
end entity gain;

architecture RTL of gain is

    signal data_after_gain  : signed(20 downto 0);
    signal ready_after_gain : std_logic;

    signal data_after_gain_resize  : signed(20 downto 0);
    signal ready_after_gain_resize : std_logic;

begin

    label_resize : process(i_clk_slow, i_reset) is
    begin
        if i_reset = '1' then
            data_after_gain_resize  <= (others => '0');
            ready_after_gain_resize <= '0';
        elsif rising_edge(i_clk_slow) then
            ready_after_gain_resize <= '0';
            if i_ready_after_filter = '1' then
                ready_after_gain_resize <= '1';
                -- Extension signée sur 21 bits pour garder de la marge avant l'application du gain par décalage.
                -- 21 c'est 16+5 donc 5 bits marge
                data_after_gain_resize  <= resize(signed(i_data_after_filter), 21);
            end if;
        end if;
    end process;

    label_gain : process(i_clk_slow, i_reset) is
    begin
        if i_reset = '1' then
            data_after_gain  <= (others => '0');
            ready_after_gain <= '0';
        elsif rising_edge(i_clk_slow) then
            ready_after_gain <= '0';
            if ready_after_gain_resize = '1' then
                ready_after_gain <= '1';
                -- Application du gain : décalage à gauche équivalent à une multiplication par 2^i_gain.
                data_after_gain  <= SHIFT_LEFT(data_after_gain_resize, To_integer(i_gain));
            end if;
        end if;
    end process;

    label_stop_overflow_gain : process(i_clk_slow, i_reset) is
    begin
        if i_reset = '1' then
            o_data_after_gain  <= (others => '0');
            o_ready_after_gain <= '0';
        elsif rising_edge(i_clk_slow) then
            o_ready_after_gain <= '0';
            if ready_after_gain = '1' then
                o_ready_after_gain <= '1';
                if data_after_gain < 32768 then
                    -- Retour au format 16 bits lorsque le résultat amplifié reste dans la plage autorisée.
                    o_data_after_gain <= resize(signed(data_after_gain), 16);
                else
                    o_data_after_gain <= To_signed(32735, 16);
                end if;

            end if;
        end if;
    end process;

end architecture RTL;
