library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Energy_level is
    port(
        i_clk_slow                : in  std_logic;
        i_reset                   : in  std_logic;
        -- ADC survey
        i_data_before_filter      : in  signed(15 downto 0);
        --input
        i_data_after_filter       : in  signed(15 downto 0);
        --input Th level
        i_TH_ADC                  : in  std_logic_vector(31 downto 0);
        i_TH_rise                 : in  std_logic_vector(31 downto 0);
        i_TH_fall                 : in  std_logic_vector(31 downto 0);
        --output
        o_Energy_level_max        : out signed(15 downto 0);
        o_readyEnergy_level_max   : out std_logic;
        --
        i_data_after_gain         : in  signed(15 downto 0);
        o_data_after_energy_level : out signed(15 downto 0)
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

                    if (i_data_before_filter > signed(i_TH_ADC(15 downto 0))) and i_TH_ADC /= x"00000000" then
                        state <= event_saturating;
                    else
                        if (i_data_after_filter > signed(i_TH_rise(15 downto 0))) and i_TH_rise /= x"00000000" then
                            state        <= event_detecting;
                            max_research <= i_data_after_filter;
                        end if;
                    end if;

                when event_detecting =>

                    o_data_after_energy_level <= i_data_after_gain;

                    if (i_data_before_filter > signed(i_TH_ADC(15 downto 0))) and i_TH_ADC /= x"00000000" then
                        state <= event_saturating;
                    else

                        if (i_data_after_filter < signed(i_TH_fall(15 downto 0))) and i_TH_fall /= x"00000000" then
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
