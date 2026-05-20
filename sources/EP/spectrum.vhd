library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spectrum is
    generic(
        memory_add_size : integer := 10;
        depth_memory    : integer := 1024
    );
    port(
        -- global
        i_clk_slow                : in  std_logic;
        i_reset                   : in  std_logic;
        -- global select spectrum
        i_clk_synchro_spectrum    : in  std_logic;
        i_detector_number         : in  unsigned;
        i_filter_number           : in  std_logic_vector(0 downto 0);
        -- input from detect Energy level
        --i_enable_erase            : in  std_logic;
        i_Energy_level_max        : in  signed(15 downto 0);
        i_readyEnergy_level_max   : in  std_logic;
        -- out spectrum to fifo pipe out
        o_pipe_out_spectrum_din   : out std_logic_vector(31 downto 0);
        o_pipe_out_spectrum_wr_en : out std_logic;
        o_spectrum_count_pulse    : out std_logic_vector(31 downto 0)
    );
end entity spectrum;

architecture RTL of spectrum is

    -- RAM 
    type Array_addr_type is array (1 downto 0) of std_logic_vector((memory_add_size - 1) downto 0);
    signal addr : Array_addr_type;
    type Array_di_type is array (1 downto 0) of std_logic_vector(15 downto 0);
    signal di   : Array_di_type;
    type Array_do_type is array (1 downto 0) of std_logic_vector(15 downto 0);
    signal do   : Array_do_type;
    signal we   : std_logic_vector(1 downto 0);
    signal en   : std_logic_vector(1 downto 0);

    --signal stamp : unsigned(15 downto 0);

    -- out spectrum to fifo pipe out
    type Array_din_type is array (1 downto 0) of std_logic_vector(31 downto 0);
    signal pipe_out_spectrum_din    : Array_din_type;
    signal pipe_out_spectrum_wr_en  : std_logic_vector(1 downto 0);
    signal spectrum_pulse_by_filter : Array_din_type;

begin

    ------------------------------------------
    -- Single-Port Block RAM No-Change Mode
    -- File: rams_sp_nc.vhd 
    ------------------------------------------

    generate_RAM : for N IN 1 downto 0 generate
        label_rame_one : entity work.rams_sp_rf
            generic map(
                memory_add_size => memory_add_size,
                depth_memory    => depth_memory
            )
            port map(
                clk  => i_clk_slow,
                we   => we(N),
                en   => en(N),
                addr => addr(N),
                di   => di(N),
                do   => do(N)
            );
    end generate generate_RAM;

    ------------------------------------------
    -- 
    -- manage read write rams_sp_nc and send pipe out spectrum
    --
    ------------------------------------------

    generate_label_spectrum_FSM : for N IN 1 downto 0 generate
        label_spectrum_FSM : entity work.spectrum_FSM
            generic map(
                memory_add_size => memory_add_size,
                depth_memory    => depth_memory
            )
            port map(
                -- global
                i_clk_slow                => i_clk_slow,
                i_reset                   => i_reset,
                i_filter_number           => i_filter_number,
                -- synchro_spectrum
                i_clk_synchro_spectrum    => i_clk_synchro_spectrum,
                i_detector_number         => i_detector_number,
                i_set_synchro_spectrum    => std_logic_vector(To_unsigned(N, 1)),
                --i_enable_erase            => i_enable_erase,
                -- RAM
                o_we                      => we(N),
                o_en                      => en(N),
                o_addr                    => addr(N),
                o_di                      => di(N),
                i_do                      => do(N),
                -- input from detect Energy level
                i_ready_energy_level_max  => i_readyEnergy_level_max,
                i_energy_level_max        => i_Energy_level_max,
                -- out spectrum to fifo pipe out
                o_pipe_out_spectrum_din   => pipe_out_spectrum_din(N),
                o_pipe_out_spectrum_wr_en => pipe_out_spectrum_wr_en(N),
                o_spectrum_count_pulse    => spectrum_pulse_by_filter(N)
            );
    end generate generate_label_spectrum_FSM;

    o_pipe_out_spectrum_din   <= pipe_out_spectrum_din(0) when i_clk_synchro_spectrum = '0' else pipe_out_spectrum_din(1);
    o_pipe_out_spectrum_wr_en <= pipe_out_spectrum_wr_en(0) when i_clk_synchro_spectrum = '0' else pipe_out_spectrum_wr_en(1);

    ------------------------------------------
    -- Cycle spectrum_pulse
    ------------------------------------------

    label_Cycle_spectrum_pulse : process(i_clk_slow, i_reset) is
    begin
        if i_reset = '1' then
            o_spectrum_count_pulse <= (others => '0');
        elsif rising_edge(i_clk_slow) then
            o_spectrum_count_pulse <= std_logic_vector(unsigned(spectrum_pulse_by_filter(0)) + unsigned(spectrum_pulse_by_filter(1)));
        end if;
    end process;

    --    label_ila : entity work.ila_0
    --        port map(
    --            clk    => i_clk_slow,
    --            probe0 => probe0
    --        );
    --    --    probe0(0)           <= pipe_in_rd_en;
    --    --    probe0(1)           <= pipe_in_valid;
    --    --    probe0(2)           <= pipe_in_empty;
    --    --    probe0(34 downto 3) <= pipe_in_dout;
    --
    --    probe0(44)           <= pipe_out_spectrum_wr_en;
    --    probe0(43)           <= en;
    --    probe0(42)           <= we;
    --    probe0(41 downto 32) <= addr;
    --    probe0(31 downto 16) <= di;
    --    probe0(15 downto 0)  <= do;

end architecture RTL;
