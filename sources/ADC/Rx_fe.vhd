library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Rx_fe is
    port(
        --global
        clk        : in     std_logic;
        rst        : in     std_logic;
        --adc
        o_sck      : out    std_logic;
        o_cs_n     : out    std_logic;
        i_sdi      : in     std_logic;
        --out adc driver
        o_data_rx  : buffer std_logic_vector(11 downto 0);
        o_ready_rx : buffer std_logic
    );
end entity Rx_fe;

architecture RTL of Rx_fe is

    type state_type is (cs_falling, send_null, send_data, acq);
    signal state : state_type;

    signal sck_count : unsigned(3 downto 0);

begin

    process(clk, rst) is
    begin
        if rst = '1' then

            state     <= cs_falling;
            -- out to ADC
            o_sck     <= '0';
            o_cs_n    <= '1';
            -- sck_count
            sck_count <= (others => '0');

            -- out to receiver    
            o_data_rx  <= (others => '0');
            o_ready_rx <= '0';

        elsif falling_edge(clk) then    -- becarful falling_edge clock

            case state is

                when cs_falling =>

                    o_cs_n <= '0';
                    state  <= send_null;

                when send_null =>

                    sck_count <= sck_count + 1;
                    if sck_count = 1 then
                        state <= send_data;
                    end if;

                when send_data =>

                    o_data_rx <= o_data_rx(10 downto 0) & i_sdi;

                    sck_count <= sck_count + 1;
                    if sck_count = 13 then
                        state     <= acq;
                        sck_count <= (others => '0');
                    end if;

                when acq =>
                    
                    sck_count <= sck_count + 1;
                    o_cs_n <= '1';
                    
                    if sck_count = 2 then
                        state <= cs_falling;
                        sck_count <= (others => '0');
                    end if;

            end case;

        end if;
    end process;

end architecture RTL;
