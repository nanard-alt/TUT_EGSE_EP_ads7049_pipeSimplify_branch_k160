library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.UT_EGSE_EP_Package.all;

entity testbench is
end entity testbench;

architecture simulation of testbench is

    constant C_CLK_PERIOD        : time    := 50 ns;
    constant C_CONFIG_WORD_COUNT : natural := 556;

    signal i_sys_clk : std_logic := '0';
    signal i_reset   : std_logic := '0';

    signal o_sck  : std_logic_vector(Detector_Number - 1 downto 0);
    signal o_cs_n : std_logic_vector(Detector_Number - 1 downto 0);
    signal i_sdi  : std_logic_vector(Detector_Number - 1 downto 0);

    --signal i_reg_global : std_logic_vector(31 downto 0) := (others => '0');

    --signal o_pipe_in_injection_rd_en : std_logic;
    --signal i_pipe_in_injection_empty : std_logic := '1';
    --signal i_pipe_in_injection_valid : std_logic := '0';
    --signal i_pipe_in_injection_dout  : std_logic_vector(31 downto 0) := (others => '0');

    signal config_spectrum_clk   : std_logic;
    signal config_spectrum_bit   : std_logic;
    signal config_spectrum_wr_en : std_logic;
    signal config_spectrum_sof   : std_logic;

    signal o_spectrum_bit      : std_logic;
    signal o_spectrum_wr_en    : std_logic;
    signal o_spectrum_clk      : std_logic;
    signal o_spectrum_sof      : std_logic;
    signal o_spectrum_sd_bit   : std_logic;
    signal o_spectrum_sd_wr_en : std_logic;
    signal o_spectrum_sd_clk   : std_logic;
    signal o_spectrum_sd_sof   : std_logic;

begin

    i_sys_clk <= not i_sys_clk after C_CLK_PERIOD / 2;

    label_reset : process
    begin
        i_reset <= '0';
        wait for 500 ns;
        wait until rising_edge(i_sys_clk);
        i_reset <= '1';
        wait;
    end process label_reset;

    -- Former i_reg_global control removed from TUT_EGSE top.
    --i_reg_global(31) <= '1';
    --i_reg_global(30) <= '0';
    --i_reg_global(29) <= '0';
    --i_reg_global(0)  <= '0';

    label_TUT_EGSE : entity work.TUT_EGSE
        port map(
            i_sys_clk => i_sys_clk,
            i_reset   => i_reset,

            o_sck  => o_sck,
            o_cs_n => o_cs_n,
            i_sdi  => i_sdi,

            --i_reg_global => i_reg_global,

            --o_pipe_in_injection_rd_en => o_pipe_in_injection_rd_en,
            --i_pipe_in_injection_empty => i_pipe_in_injection_empty,
            --i_pipe_in_injection_valid => i_pipe_in_injection_valid,
            --i_pipe_in_injection_dout  => i_pipe_in_injection_dout,

            i_config_clk   => config_spectrum_clk,
            i_config_bit   => config_spectrum_bit,
            i_config_wr_en => config_spectrum_wr_en,
            i_config_sof   => config_spectrum_sof,

            o_spectrum_bit      => o_spectrum_bit,
            o_spectrum_wr_en    => o_spectrum_wr_en,
            o_spectrum_clk      => o_spectrum_clk,
            o_spectrum_sof      => o_spectrum_sof,
            o_spectrum_sd_bit   => o_spectrum_sd_bit,
            o_spectrum_sd_wr_en => o_spectrum_sd_wr_en,
            o_spectrum_sd_clk   => o_spectrum_sd_clk,
            o_spectrum_sd_sof   => o_spectrum_sd_sof,

            o_DAC_SCLK   => open,
            o_DAC_SYNC_n => open,
            o_DAC_DIN    => open,
            o_DAC_on_off => open
        );

    label_OBC_Emulator : entity work.OBC_Emulator
        generic map(
            G_SPECTRUM_FILE    => "OBC_spectrum.hex",
            G_SPECTRUM_SD_FILE => "OBC_spectrum_sd.hex",
            G_CONFIG_FILE      => "coef_HEX_V2.txt",
            G_CONFIG_WORD_COUNT => C_CONFIG_WORD_COUNT
        )
        port map(
            i_reset          => i_reset,
            i_config_clk     => i_sys_clk,
            o_spectrum_clk   => config_spectrum_clk,
            o_spectrum_bit   => config_spectrum_bit,
            o_spectrum_wr_en => config_spectrum_wr_en,
            o_spectrum_sof   => config_spectrum_sof,

            i_spectrum_clk      => o_spectrum_clk,
            i_spectrum_bit      => o_spectrum_bit,
            i_spectrum_wr_en    => o_spectrum_wr_en,
            i_spectrum_sof      => o_spectrum_sof,
            i_spectrum_sd_clk   => o_spectrum_sd_clk,
            i_spectrum_sd_bit   => o_spectrum_sd_bit,
            i_spectrum_sd_wr_en => o_spectrum_sd_wr_en,
            i_spectrum_sd_sof   => o_spectrum_sd_sof
        );

    generate_label_ADS7049_Emulators : for N in 0 to Detector_Number - 1 generate
        label_ADS7049_Emulators : entity work.ADS7049_Emulators
            port map(
                i_Rst_n => i_reset,
                i_sck   => o_sck(N),
                i_cs_n  => o_cs_n(N),
                o_sdo   => i_sdi(N)
            );
    end generate generate_label_ADS7049_Emulators;

end architecture simulation;


