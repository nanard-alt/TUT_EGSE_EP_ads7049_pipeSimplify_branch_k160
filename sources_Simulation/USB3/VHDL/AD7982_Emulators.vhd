
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use work.FrontPanel.all;

library STD;
use std.textio.all;

entity AD7982_Emulators is
    port(
        --------------------------------------------------------------------------------------------
        -- Reset
        --------------------------------------------------------------------------------------------
        i_Rst_n : in  std_logic;        -- General Reset, negative polarity

        --adc
        i_sck   : in  std_logic;
        i_cnv   : in  std_logic;
        o_sdo   : out std_logic
    );
end AD7982_Emulators;

architecture Simulation of AD7982_Emulators is

    signal SPI_Bit_Number_cnt        : unsigned(4 downto 0); -- 18-bit standard SPI protocol
    signal pattern_data_counter      : signed(17 downto 0);
    signal pattern_data_counter_save : signed(17 downto 0);
    signal ADC_data                  : signed(17 downto 0);

begin

    label_read_file_ADC : process
        ------------------------------------------------------------------

        file DONNEES     : text;
        variable MY_LINE : line;
        variable data    : std_logic_vector(15 downto 0);

        -------------------------------------------------------------------

    begin                               -------------begin of process-----
        file_open(DONNEES, "Signal_ADC.txt", read_mode);
        data     := (others => '0');
        ADC_data <= (others => '0');

        --wait for 500 us;

        wait until i_Rst_n = '0' and i_Rst_n'event;
        
        wait for 19180 us;

        loop

            wait until rising_edge(i_cnv);

            if (not endfile(DONNEES)) then

                readline(DONNEES, MY_LINE);
                hread(MY_LINE, data);
                ADC_data <= resize(signed(data), 18);

            else
            --ep_write  <= '0';
            end if;

        end loop;                       ---------

    end process;

    AD7982_Emulators_SPI_Protocol : process
    begin
        SPI_Bit_Number_cnt   <= b"10010";
        pattern_data_counter <= (others => '0');
        o_sdo                <= '0';
        wait until i_Rst_n = '1';

        while True loop

            --wait until rising_edge(i_cnv); --  init a conversion

            o_sdo <= '0';

            wait until falling_edge(i_cnv); --  init a conversion

            pattern_data_counter <= ADC_data;

            Conversion : while SPI_Bit_Number_cnt > b"00000" loop

                wait until rising_edge(i_sck);

                --o_sdo                <= pattern_data_counter((To_integer(SPI_Bit_Number_cnt))-1);
                o_sdo <= pattern_data_counter(17);

                wait until falling_edge(i_sck);

                SPI_Bit_Number_cnt <= SPI_Bit_Number_cnt - "1";

                wait for 1 ns;

                pattern_data_counter <= pattern_data_counter(16 downto 0) & '0';

            end loop Conversion;

            wait for 20 ns;
            o_sdo              <= '0';
            wait for 1 ns;
            SPI_Bit_Number_cnt <= b"10010";
            wait for 1 ns;

        end loop;
    end process AD7982_Emulators_SPI_Protocol;

end architecture Simulation;
