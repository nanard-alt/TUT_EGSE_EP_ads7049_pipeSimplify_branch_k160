
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use work.FrontPanel.all;

library STD;
use std.textio.all;

entity ADS7049_Emulators is
    port(
        --------------------------------------------------------------------------------------------
        -- Reset
        --------------------------------------------------------------------------------------------
        i_Rst_n : in  std_logic;        -- General Reset, negative polarity

        --adc
        i_sck   : in  std_logic;
        i_cs_n  : in  std_logic;
        o_sdo   : out std_logic
    );
end ADS7049_Emulators;

architecture Simulation of ADS7049_Emulators is

    constant tDV_CSDO : time := 10 ns;
    constant tD_CKDO  : time := 25 ns;
    constant tD_CKCS  : time := 10 ns;
    constant tDZ_CSDO : time := 5 ns;

    signal SPI_Bit_Number_cnt        : unsigned(4 downto 0); -- 18-bit standard SPI protocol
    signal pattern_data_counter      : unsigned(11 downto 0);
    signal pattern_data_counter_save : unsigned(11 downto 0);
    signal ADC_data_offset           : signed(16 downto 0);
    signal signed_data               : signed(11 downto 0);
    signal ADC_data_pattern          : unsigned(11 downto 0);

begin

    label_read_file_ADC : process
        ------------------------------------------------------------------

        file DONNEES     : text;
        variable MY_LINE : line;
        variable data    : std_logic_vector(11 downto 0);

        -------------------------------------------------------------------

    begin                               -------------begin of process-----
        file_open(DONNEES, "Signal_ADC.txt", read_mode);
        data             := (others => '0');
        ADC_data_pattern <= (others => '0');

        --wait for 500 us;

        wait until i_Rst_n = '1' and i_Rst_n'event;

        wait for 10 us;

        loop

            wait until rising_edge(i_cs_n);

            if (not endfile(DONNEES)) then

                readline(DONNEES, MY_LINE);
                hread(MY_LINE, data);
                ADC_data_pattern <= unsigned(data);
                signed_data <= signed(data);


            else
            --ep_write  <= '0';
            end if;

        end loop;                       ---------

    end process;

    ADS7049_Emulators_SPI_Protocol : process
    begin
        SPI_Bit_Number_cnt        <= b"01011";
        --pattern_data_counter <= b"010101010101";
        pattern_data_counter      <= b"000000000000";
        pattern_data_counter_save <= b"000000000000";
        o_sdo                     <= '0';

        wait until falling_edge(i_Rst_n);

        --------------------------------------------------------------------
        --
        --  Calibration on POWER UP
        --
        --------------------------------------------------------------------

        --------------------------------------------------------------------
        --
        --  Normal Operation
        --
        --------------------------------------------------------------------

        while True loop

            SPI_Bit_Number_cnt <= b"01011";

            o_sdo <= 'Z';

            wait until falling_edge(i_cs_n); --  init a conversion for science

            wait for tDV_CSDO;          -- tDV_CSDO

            o_sdo <= '0';               -- first zero on data

            wait until falling_edge(i_sck) and i_cs_n = '0';

            wait for tD_CKDO;           -- tD_CKDO

            o_sdo <= '0';               -- second zero on data

            Conversion : while SPI_Bit_Number_cnt > b"00000" loop

                wait until falling_edge(i_sck) and i_cs_n = '0';

                wait for tD_CKDO;       -- tD_CKDO

                o_sdo <= pattern_data_counter(To_integer(SPI_Bit_Number_cnt)); -- bit 11 to 1
                --o_sdo <= pattern_data_counter(11);

                wait for 1 ns;

                SPI_Bit_Number_cnt <= SPI_Bit_Number_cnt - "1";

                wait for 1 ns;

                --pattern_data_counter <= pattern_data_counter(10 downto 0) & '0';

            end loop Conversion;

            wait until falling_edge(i_sck) and i_cs_n = '0';

            wait for tD_CKDO;           -- tD_CKDO

            o_sdo <= pattern_data_counter(To_integer(SPI_Bit_Number_cnt)); -- bit 0

            --wait until falling_edge(i_sck) and i_cs_n = '0';

            wait for tD_CKCS;           -- tD_CKCS

            wait until rising_edge(i_cs_n);

            pattern_data_counter      <= ADC_data_pattern;
            pattern_data_counter_save <= ADC_data_pattern;

            wait for tDZ_CSDO;          -- tDZ_CSDO

            o_sdo <= 'Z';

        end loop;
    end process ADS7049_Emulators_SPI_Protocol;

end architecture Simulation;
