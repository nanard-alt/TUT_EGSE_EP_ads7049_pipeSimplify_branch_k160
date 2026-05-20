library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gain is
    port(
        -- global
        i_clk_slow           : in  std_logic;
        i_reset              : in  std_logic;
        -- input gain       
        i_gain               : in  unsigned(31 downto 0);
        -- input data
        i_data_after_filter  : in  signed(15 downto 0);
        i_ready_after_filter : in  std_logic;
        -- output data
        o_data_after_gain    : out signed(15 downto 0);
        o_ready_after_gain   : out std_logic
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
                    o_data_after_gain <= resize(signed(data_after_gain), 16);
                else
                    o_data_after_gain <= To_signed(32735, 16);
                end if;

            end if;
        end if;
    end process;

end architecture RTL;
