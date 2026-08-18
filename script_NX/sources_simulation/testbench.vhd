library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

use work.UT_EGSE_EP_Package.all;

entity testbench is
end entity testbench;

architecture simulation of testbench is

    constant C_CLK_PERIOD        : time    := 50 ns;
    constant C_CONFIG_WORD_COUNT : natural := 556;

    signal i_sys_clk : std_logic := '0';
    signal i_reset   : std_logic := '1';

    signal o_sck  : std_logic_vector(Detector_Number - 1 downto 0);
    signal o_cs_n : std_logic_vector(Detector_Number - 1 downto 0);
    signal i_sdi  : std_logic_vector(Detector_Number - 1 downto 0);

    signal i_reg_global : std_logic_vector(31 downto 0) := (others => '0');

    signal o_pipe_in_injection_rd_en : std_logic;
    signal i_pipe_in_injection_empty : std_logic := '1';
    signal i_pipe_in_injection_valid : std_logic := '0';
    signal i_pipe_in_injection_dout  : std_logic_vector(31 downto 0) := (others => '0');

    signal o_pipe_in_config_rd_en      : std_logic;
    signal i_pipe_in_config_empty      : std_logic := '0';
    signal i_pipe_in_config_valid      : std_logic := '0';
    signal i_pipe_in_config_dout       : std_logic_vector(31 downto 0) := (others => '0');
    signal i_pipe_in_config_data_count : std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(C_CONFIG_WORD_COUNT, 10));

begin

    i_sys_clk <= not i_sys_clk after C_CLK_PERIOD / 2;

    label_reset : process
    begin
        i_reset <= '1';
        wait for 500 ns;
        wait until rising_edge(i_sys_clk);
        i_reset <= '0';
        wait;
    end process label_reset;

    -- Bit 31 = 1 selects the ADS7049 path instead of injection.
    i_reg_global(31) <= '1';
    i_reg_global(30) <= '0';
    i_reg_global(29) <= '0';
    i_reg_global(0)  <= '0';

    label_TUT_EGSE : entity work.TUT_EGSE
        port map(
            i_sys_clk => i_sys_clk,
            i_reset   => i_reset,

            o_sck  => o_sck,
            o_cs_n => o_cs_n,
            i_sdi  => i_sdi,

            i_reg_global => i_reg_global,

            o_pipe_in_injection_rd_en => o_pipe_in_injection_rd_en,
            i_pipe_in_injection_empty => i_pipe_in_injection_empty,
            i_pipe_in_injection_valid => i_pipe_in_injection_valid,
            i_pipe_in_injection_dout  => i_pipe_in_injection_dout,

            o_pipe_in_config_rd_en      => o_pipe_in_config_rd_en,
            i_pipe_in_config_empty      => i_pipe_in_config_empty,
            i_pipe_in_config_valid      => i_pipe_in_config_valid,
            i_pipe_in_config_dout       => i_pipe_in_config_dout,
            i_pipe_in_config_data_count => i_pipe_in_config_data_count,

            pipe_out_spectrum_din      => open,
            pipe_out_spectrum_wr_en    => open,
            pipe_out_spectrum_sd_din   => open,
            pipe_out_spectrum_sd_wr_en => open,

            o_DAC_SCLK   => open,
            o_DAC_SYNC_n => open,
            o_DAC_DIN    => open,
            o_DAC_on_off => open
        );

    label_config_fifo_model : process(i_sys_clk)
        file coef_file           : text open read_mode is "coef_HEX_V2.txt";
        variable line_buffer     : line;
        variable hex_word_16     : std_logic_vector(15 downto 0);
        variable pending_valid   : std_logic := '0';
        variable pending_dout    : std_logic_vector(31 downto 0) := (others => '0');
        variable remaining_words : natural := C_CONFIG_WORD_COUNT;
    begin
        if rising_edge(i_sys_clk) then
            if i_reset = '1' then
                i_pipe_in_config_valid      <= '0';
                i_pipe_in_config_dout       <= (others => '0');
                i_pipe_in_config_empty      <= '0';
                i_pipe_in_config_data_count <= std_logic_vector(to_unsigned(C_CONFIG_WORD_COUNT, 10));
                pending_valid               := '0';
                pending_dout                := (others => '0');
                remaining_words             := C_CONFIG_WORD_COUNT;
            else
                i_pipe_in_config_valid <= pending_valid;
                i_pipe_in_config_dout  <= pending_dout;
                pending_valid          := '0';

                if o_pipe_in_config_rd_en = '1' and remaining_words > 0 then
                    if not endfile(coef_file) then
                        readline(coef_file, line_buffer);
                        hread(line_buffer, hex_word_16);
                        pending_dout              := (others => '0');
                        pending_dout(15 downto 0) := hex_word_16;
                        pending_valid             := '1';
                        remaining_words           := remaining_words - 1;
                    else
                        pending_dout     := (others => '0');
                        pending_valid    := '0';
                        remaining_words  := 0;
                    end if;
                end if;

                if remaining_words = 0 then
                    i_pipe_in_config_empty <= '1';
                else
                    i_pipe_in_config_empty <= '0';
                end if;

                i_pipe_in_config_data_count <= std_logic_vector(to_unsigned(remaining_words, 10));
            end if;
        end if;
    end process label_config_fifo_model;

    generate_label_ADS7049_Emulators : for N in 0 to Detector_Number - 1 generate
        label_ADS7049_Emulators : entity work.ADS7049_Emulators
            port map(
                i_Rst_n => not i_reset,
                i_sck   => o_sck(N),
                i_cs_n  => o_cs_n(N),
                o_sdo   => i_sdi(N)
            );
    end generate generate_label_ADS7049_Emulators;

end architecture simulation;


