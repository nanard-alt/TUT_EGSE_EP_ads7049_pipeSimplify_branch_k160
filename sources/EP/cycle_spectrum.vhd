library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cycle_spectrum is
    port(
        sys_clk                : in  std_logic;
        reset                  : in  std_logic;
        
        o_clk_synchro_spectrum : out std_logic
    );
end entity cycle_spectrum;

architecture RTL of cycle_spectrum is

    signal count_synchro_spectrum      : unsigned(26 downto 0);
    signal clk_synchro_spectrum        : std_logic;

begin

    process(sys_clk, reset) is
    begin
        if reset = '1' then

            count_synchro_spectrum <= (others => '0');
            clk_synchro_spectrum   <= '0';

        elsif rising_edge(sys_clk) then

            count_synchro_spectrum <= count_synchro_spectrum + 1;
            
            if To_integer(count_synchro_spectrum) >= 20000000 then
                clk_synchro_spectrum   <= not clk_synchro_spectrum;
                count_synchro_spectrum <= (others => '0');
            end if;

        end if;
    end process;

    o_clk_synchro_spectrum <= clk_synchro_spectrum;

end architecture RTL;