library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity OBC_Emulator is
    generic (
        G_SPECTRUM_FILE    : string := "OBC_spectrum.hex";
        G_SPECTRUM_SD_FILE : string := "OBC_spectrum_sd.hex"
    );
    port (
        i_reset : in std_logic;

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
begin

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

end architecture simulation;
