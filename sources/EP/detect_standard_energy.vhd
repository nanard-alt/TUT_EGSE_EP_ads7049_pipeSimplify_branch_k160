library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity detect_standard_energy is
    port(
        i_clk_slow                  : in  std_logic;
        i_reset                     : in  std_logic;
        -- input from detect Energy level
        i_ready_energy_level_max    : in  std_logic;
        i_energy_level_max          : in  signed(15 downto 0);
        -- output from detect Energy level
        o_ready_energy_level_max_sd : out std_logic;
        o_energy_level_max_sd       : out signed(15 downto 0)
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

        if i_energy_level_max >= 0 and i_energy_level_max < 6553 and i_ready_energy_level_max = '1' then
            o_ready_energy_level_max_sd <= '1';
            o_energy_level_max_sd       <= x"1000";
        else
            if i_energy_level_max >= 6553 and i_energy_level_max < 13106 and i_ready_energy_level_max = '1' then
                o_ready_energy_level_max_sd <= '1';
                o_energy_level_max_sd       <= x"2000";
            else
                if i_energy_level_max >= 13106 and i_energy_level_max < 19659 and i_ready_energy_level_max = '1' then
                    o_ready_energy_level_max_sd <= '1';
                    o_energy_level_max_sd       <= x"3000";
                else
                    if i_energy_level_max >= 19659 and i_energy_level_max < 26212 and i_ready_energy_level_max = '1' then
                        o_ready_energy_level_max_sd <= '1';
                        o_energy_level_max_sd       <= x"4000";
                    else
                        if i_energy_level_max >= 26212 and i_energy_level_max <= 32767 and i_ready_energy_level_max = '1' then
                            o_ready_energy_level_max_sd <= '1';
                            o_energy_level_max_sd       <= x"5000";
                        end if;
                    end if;
                end if;
            end if;
        end if;
        
    end if;    
    end process;

end architecture RTL;
