library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity remote_DAC121S01_driver is
    port(
        -- Reset and Clock
        i_Rst_n       : in  std_logic;  -- General Reset, negative polarity
        i_Clk         : in  std_logic;  -- State Machine clock, FSM_freq = 2*Converting_freq
        -- Control DAC
        o_Start       : out std_logic;  -- Start converting
        i_Busy        : in  std_logic;  -- Busy flag when data register is converted
        o_Num_Data    : out std_logic_vector(11 downto 0); -- Input data register to convert
        -- setting
        level_DAC121S : in  std_logic_vector(31 downto 0)
    );
end entity remote_DAC121S01_driver;

architecture RTL of remote_DAC121S01_driver is

    type state_type is (state0, state1, state2);
    signal count_send_DAC_data : unsigned(7 downto 0);
    signal state               : state_type := state0;

begin

    process(i_Clk, i_Rst_n) is
    begin
        if i_Rst_n = '0' then

            state               <= state0;
            count_send_DAC_data <= (others => '0');
            o_Start             <= '0';
            o_Num_Data          <= (others => '0');

        elsif rising_edge(i_Clk) then
            case state is
                when state0 =>

                    count_send_DAC_data <= count_send_DAC_data + 1;

                    if To_integer(count_send_DAC_data) >= 100 then -- every ten ms
                        count_send_DAC_data <= (others => '0');
                        state               <= state1;
                    end if;

                when state1 =>

                    if i_Busy = '0' then
                        o_Start    <= '1';
                        o_Num_Data <= level_DAC121S(11 downto 0);
                        state      <= state2;
                    end if;

                when state2 =>

                    o_Start <= '0';

                    if i_Busy = '1' then
                        state <= state0;
                    end if;

            end case;
        end if;
    end process;

end architecture RTL;
