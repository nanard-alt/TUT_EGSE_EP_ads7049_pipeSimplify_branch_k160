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

entity Energy_level is
    port(
        -- global
        i_clk_slow                : in  std_logic; -- horloge systeme lente
        i_reset                   : in  std_logic; -- reset actif a 1

        -- surveillance ADC avant filtrage
        i_data_before_filter      : in  signed(15 downto 0); -- echantillon avant filtre, utilise pour detecter la saturation ADC

        -- entree detection energie apres filtrage
        i_data_after_filter       : in  signed(15 downto 0); -- echantillon filtre utilise pour rechercher le maximum d'energie

        -- seuils de detection
        i_TH_ADC                  : in  std_logic_vector(15 downto 0); -- seuil saturation ADC, 0 desactive le test
        i_TH_rise                 : in  std_logic_vector(15 downto 0); -- seuil de debut evenement, 0 desactive le test
        i_TH_fall                 : in  std_logic_vector(15 downto 0); -- seuil de fin evenement, 0 desactive le test

        -- sortie niveau d'energie
        o_Energy_level_max        : out signed(15 downto 0); -- maximum d'energie mesure pendant l'evenement
        o_readyEnergy_level_max   : out std_logic; -- pulse indiquant que o_Energy_level_max est valide

        -- recopie du flux apres gain
        i_data_after_gain         : in  signed(15 downto 0); -- echantillon apres gain
        o_data_after_energy_level : out signed(15 downto 0) -- echantillon apres traitement Energy_level
    );
end entity Energy_level;

architecture RTL of Energy_level is
    type state_type is (init, event_detecting, event_detecting_finish, event_saturating, event_saturating_waiting);
    signal max_research : signed(15 downto 0);
    signal state        : state_type := init;

    signal count_event_saturating_waiting : unsigned(15 downto 0);

begin

    process(i_clk_slow, i_reset) is
    begin
        if i_reset = '1' then

            state                          <= init;
            max_research                   <= (others => '0');
            o_Energy_level_max             <= (others => '0');
            o_readyEnergy_level_max        <= '0';
            count_event_saturating_waiting <= (others => '0');
            o_data_after_energy_level      <= (others => '0');

        elsif rising_edge(i_clk_slow) then

            case state is

                when init =>

                    o_data_after_energy_level <= i_data_after_gain;
                    o_readyEnergy_level_max   <= '0';

                    if (i_data_before_filter > signed(i_TH_ADC)) and i_TH_ADC /= x"0000" then
                        state <= event_saturating;
                    else
                        if (i_data_after_filter > signed(i_TH_rise)) and i_TH_rise /= x"0000" then
                            state        <= event_detecting;
                            max_research <= i_data_after_filter;
                        end if;
                    end if;

                when event_detecting =>

                    o_data_after_energy_level <= i_data_after_gain;

                    if (i_data_before_filter > signed(i_TH_ADC)) and i_TH_ADC /= x"0000" then
                        state <= event_saturating;
                    else

                        if (i_data_after_filter < signed(i_TH_fall)) and i_TH_fall /= x"0000" then
                            state <= event_detecting_finish;
                        else
                            if (i_data_after_filter >= max_research) then
                                max_research <= i_data_after_filter;
                            end if;
                        end if;
                    end if;

                when event_detecting_finish =>

                    o_data_after_energy_level <= i_data_after_gain;

                    state                   <= init;
                    o_Energy_level_max      <= max_research;
                    o_readyEnergy_level_max <= '1';

                when event_saturating =>

                    o_data_after_energy_level <= To_signed(32767, 16);

                    state                   <= event_saturating_waiting;
                    o_Energy_level_max      <= "0111111111100000";
                    o_readyEnergy_level_max <= '1';

                when event_saturating_waiting =>

                    o_data_after_energy_level <= To_signed(32767, 16);

                    o_readyEnergy_level_max <= '0';

                    count_event_saturating_waiting <= count_event_saturating_waiting + 1;

                    if To_integer(count_event_saturating_waiting) >= 500 then -- wait 25us
                        state                          <= init;
                        count_event_saturating_waiting <= (others => '0');
                    end if;

            end case;
        end if;
    end process;

end architecture RTL;
