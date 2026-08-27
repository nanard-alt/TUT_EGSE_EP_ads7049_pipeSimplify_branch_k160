library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity OBC_Emulator is
    generic (
        G_SPECTRUM_FILE    : string := "OBC_spectrum.hex";
        G_SPECTRUM_SD_FILE : string := "OBC_spectrum_sd.hex";
        G_CONFIG_FILE      : string := "coef_HEX_V2.txt";
        G_CONFIG_WORD_COUNT : natural := 556
    );
    port (
        i_reset : in std_logic;

        i_config_clk      : in  std_logic;
        o_spectrum_clk    : out std_logic;
        o_spectrum_bit    : out std_logic;
        o_spectrum_wr_en : out std_logic;
        o_spectrum_sof    : out std_logic;

        i_spectrum_clk   : in std_logic;
        i_spectrum_bit   : in std_logic;
        i_spectrum_wr_en : in std_logic;
        i_spectrum_sof   : in std_logic;

        i_spectrum_sd_clk   : in std_logic;
        i_spectrum_sd_bit   : in std_logic;
        i_spectrum_sd_wr_en : in std_logic;
        i_spectrum_sd_sof   : in std_logic
    );
end entity OBC_Emulator;

architecture simulation of OBC_Emulator is
    type config_state_type is (CONFIG_IDLE, CONFIG_SHIFT, CONFIG_DONE);

    signal config_state     : config_state_type := CONFIG_IDLE;
    signal config_shift_reg : std_logic_vector(31 downto 0) := (others => '0');
    signal config_bit_count : unsigned(5 downto 0) := (others => '0');
    signal config_word_count : natural range 0 to G_CONFIG_WORD_COUNT := 0;
    signal config_bit       : std_logic := '0';
    signal config_wr_en     : std_logic := '0';
    signal config_sof       : std_logic := '0';
begin

    label_send_config : process(i_config_clk)
        file config_file       : text open read_mode is G_CONFIG_FILE;
        variable line_buffer   : line;
        variable hex_word_16   : std_logic_vector(15 downto 0);
        variable config_word_32 : std_logic_vector(31 downto 0);
    begin
        if rising_edge(i_config_clk) then
            if i_reset = '1' then
                config_state     <= CONFIG_IDLE;
                config_shift_reg <= (others => '0');
                config_bit_count <= (others => '0');
                config_word_count <= 0;
                config_bit       <= '0';
                config_wr_en     <= '0';
                config_sof       <= '0';

            else
                config_wr_en <= '0';
                config_sof   <= '0';

                case config_state is
                    when CONFIG_IDLE =>
                        if config_word_count < G_CONFIG_WORD_COUNT and not endfile(config_file) then
                            readline(config_file, line_buffer);
                            hread(line_buffer, hex_word_16);
                            config_word_32 := (others => '0');
                            config_word_32(15 downto 0) := hex_word_16;
                            config_shift_reg <= config_word_32;
                            config_bit_count <= to_unsigned(31, config_bit_count'length);
                            config_state     <= CONFIG_SHIFT;
                        else
                            config_state <= CONFIG_DONE;
                        end if;

                    when CONFIG_SHIFT =>
                        config_bit   <= config_shift_reg(31);
                        config_wr_en <= '1';

                        if config_bit_count = to_unsigned(31, config_bit_count'length) then
                            config_sof <= '1';
                        end if;

                        config_shift_reg <= config_shift_reg(30 downto 0) & '0';

                        if config_bit_count = 0 then
                            config_word_count <= config_word_count + 1;
                            config_state      <= CONFIG_IDLE;
                        else
                            config_bit_count <= config_bit_count - 1;
                        end if;

                    when CONFIG_DONE =>
                        config_state <= CONFIG_DONE;
                end case;
            end if;
        end if;
    end process label_send_config;

    label_capture_spectrum : process(i_spectrum_clk)
        file spectrum_file       : text open write_mode is G_SPECTRUM_FILE;
        variable line_buffer     : line;
        variable shift_reg       : std_logic_vector(31 downto 0) := (others => '0');
        variable next_word       : std_logic_vector(31 downto 0);
        variable bit_count       : natural range 0 to 31 := 0;
        variable frame_is_active : boolean := false;
    begin
        if rising_edge(i_spectrum_clk) then
            if i_reset = '1' then
                shift_reg       := (others => '0');
                bit_count       := 0;
                frame_is_active := false;
            else
                if i_spectrum_wr_en = '1' then
                    if i_spectrum_sof = '1' then
                        shift_reg       := (others => '0');
                        bit_count       := 0;
                        frame_is_active := true;
                    end if;

                    if frame_is_active then
                        next_word := shift_reg(30 downto 0) & i_spectrum_bit;
                        shift_reg := next_word;

                        if bit_count = 31 then
                            hwrite(line_buffer, next_word);
                            writeline(spectrum_file, line_buffer);
                            bit_count       := 0;
                            frame_is_active := false;
                        else
                            bit_count := bit_count + 1;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process label_capture_spectrum;

    label_capture_spectrum_sd : process(i_spectrum_sd_clk)
        file spectrum_sd_file    : text open write_mode is G_SPECTRUM_SD_FILE;
        variable line_buffer     : line;
        variable shift_reg       : std_logic_vector(31 downto 0) := (others => '0');
        variable next_word       : std_logic_vector(31 downto 0);
        variable bit_count       : natural range 0 to 31 := 0;
        variable frame_is_active : boolean := false;
    begin
        if rising_edge(i_spectrum_sd_clk) then
            if i_reset = '1' then
                shift_reg       := (others => '0');
                bit_count       := 0;
                frame_is_active := false;
            else
                if i_spectrum_sd_wr_en = '1' then
                    if i_spectrum_sd_sof = '1' then
                        shift_reg       := (others => '0');
                        bit_count       := 0;
                        frame_is_active := true;
                    end if;

                    if frame_is_active then
                        next_word := shift_reg(30 downto 0) & i_spectrum_sd_bit;
                        shift_reg := next_word;

                        if bit_count = 31 then
                            hwrite(line_buffer, next_word);
                            writeline(spectrum_sd_file, line_buffer);
                            bit_count       := 0;
                            frame_is_active := false;
                        else
                            bit_count := bit_count + 1;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process label_capture_spectrum_sd;

    o_spectrum_bit   <= config_bit;
    o_spectrum_wr_en <= config_wr_en;
    o_spectrum_clk   <= i_config_clk;
    o_spectrum_sof   <= config_sof;

end architecture simulation;
