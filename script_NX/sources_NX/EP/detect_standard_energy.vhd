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

entity detect_standard_energy is
    port(
        -- global
        i_clk_slow                  : in  std_logic; -- horloge systeme lente
        i_reset                     : in  std_logic; -- reset actif a 1

        -- configuration des seuils
        i_standard_energy_threshold : in  Array_config_10x16_type; -- 6 seuils 16 bits pour classer l'energie standard

        -- entree depuis Energy_level
        i_ready_energy_level_max    : in  std_logic; -- pulse indiquant que i_energy_level_max est valide
        i_energy_level_max          : in  signed(15 downto 0); -- energie maximale detectee, signee 16 bits

        -- sortie vers construction du spectrum standard definition
        o_ready_energy_level_max_sd : out std_logic; -- pulse indiquant que o_energy_level_max_sd est valide
        o_energy_level_max_sd       : out signed(15 downto 0) -- classe energie standard encodee sur 16 bits
    );
end entity detect_standard_energy;

architecture RTL of detect_standard_energy is

begin

    ------------------------------------------
    -- detect standard energy
    ------------------------------------------

    label_detect_standard_energy : process(i_clk_slow, i_reset) is
    begin
        if i_reset = '1' then

            o_energy_level_max_sd       <= (others => '0');
            o_ready_energy_level_max_sd <= '0';

        elsif rising_edge(i_clk_slow) then

            o_ready_energy_level_max_sd <= '0';

            if i_ready_energy_level_max = '1' then

                if i_energy_level_max >= i_standard_energy_threshold(0) and i_energy_level_max < i_standard_energy_threshold(1) then
                    -- standard_energy_threshold(0..1): 0 <= energy < 6553

                    o_ready_energy_level_max_sd <= '1';
                    o_energy_level_max_sd       <= x"1000";

                elsif i_energy_level_max >= i_standard_energy_threshold(1) and i_energy_level_max < i_standard_energy_threshold(2) then
                    -- standard_energy_threshold(1..2): 6553 <= energy < 13106

                    o_ready_energy_level_max_sd <= '1';
                    o_energy_level_max_sd       <= x"2000";

                elsif i_energy_level_max >= i_standard_energy_threshold(2) and i_energy_level_max < i_standard_energy_threshold(3) then
                    -- standard_energy_threshold(2..3): 13106 <= energy < 19659

                    o_ready_energy_level_max_sd <= '1';
                    o_energy_level_max_sd       <= x"3000";

                elsif i_energy_level_max >= i_standard_energy_threshold(3) and i_energy_level_max < i_standard_energy_threshold(4) then
                    -- standard_energy_threshold(3..4): 19659 <= energy < 26212

                    o_ready_energy_level_max_sd <= '1';
                    o_energy_level_max_sd       <= x"4000";

                elsif i_energy_level_max >= i_standard_energy_threshold(4) and i_energy_level_max <= i_standard_energy_threshold(5) then
                    -- standard_energy_threshold(4..5): 26212 <= energy <= 32767

                    o_ready_energy_level_max_sd <= '1';
                    o_energy_level_max_sd       <= x"5000";

                end if;
            end if;

        end if;

    end process;

end architecture RTL;
