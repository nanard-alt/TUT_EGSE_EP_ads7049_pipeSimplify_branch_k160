library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity config_unserializer is
    port (
        i_clk        : in  std_logic;
        i_reset      : in  std_logic;
        i_serial_bit : in  std_logic;
        i_wr_en      : in  std_logic;
        i_sof        : in  std_logic;
        o_word       : out std_logic_vector(31 downto 0);
        o_word_valid : out std_logic
    );
end entity config_unserializer;

architecture RTL of config_unserializer is
    signal shift_reg    : std_logic_vector(31 downto 0);
    signal bit_count    : unsigned(5 downto 0);
    signal frame_active : std_logic;
    signal word_reg     : std_logic_vector(31 downto 0);
    signal word_valid   : std_logic;
begin

    deserialize_config : process(i_clk, i_reset) is
        variable next_word : std_logic_vector(31 downto 0);
    begin
        if i_reset = '1' then
            shift_reg    <= (others => '0');
            bit_count    <= (others => '0');
            frame_active <= '0';
            word_reg     <= (others => '0');
            word_valid   <= '0';

        elsif rising_edge(i_clk) then
            word_valid <= '0';

            if i_wr_en = '1' then
                if i_sof = '1' then
                    next_word := (others => '0');
                    next_word(0) := i_serial_bit;
                    shift_reg    <= next_word;
                    bit_count    <= to_unsigned(1, bit_count'length);
                    frame_active <= '1';

                elsif frame_active = '1' then
                    next_word := shift_reg(30 downto 0) & i_serial_bit;
                    shift_reg <= next_word;

                    if bit_count = to_unsigned(31, bit_count'length) then
                        word_reg     <= next_word;
                        word_valid   <= '1';
                        bit_count    <= (others => '0');
                        frame_active <= '0';
                    else
                        bit_count <= bit_count + 1;
                    end if;
                end if;
            end if;
        end if;
    end process deserialize_config;

    o_word       <= word_reg;
    o_word_valid <= word_valid;

end architecture RTL;
