-- Spectrum RAM wrapper.
--
-- Large spectrum memories are explicitly mapped to NanoXplore NX_RAM_WRAP.
-- Small spectrum memories use a plain VHDL RAM while the NX RFB model is debugged.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library nx;
use nx.nxPackage.all;

entity rams_sp_rf is
    generic(
        memory_add_size : integer := 10;
        depth_memory    : integer := 1024
    );
    port(
        clk  : in  std_logic;
        we   : in  std_logic;
        en   : in  std_logic;
        addr : in  std_logic_vector(memory_add_size-1 downto 0);
        di   : in  std_logic_vector(15 downto 0);
        do   : out std_logic_vector(15 downto 0)
    );
end rams_sp_rf;

architecture syn of rams_sp_rf is
    signal nx_addr : std_logic_vector(15 downto 0);
    signal nx_di   : std_logic_vector(23 downto 0);
    signal nx_do   : std_logic_vector(23 downto 0);

begin

    generate_nx_ram : if depth_memory > 128 generate
        nx_addr(15 downto memory_add_size)    <= (others => '0');
        nx_addr(memory_add_size - 1 downto 0) <= addr;

        nx_di(23 downto 16) <= (others => '0');
        nx_di(15 downto 0)  <= di;

        do <= nx_do(15 downto 0);

        label_NX_RAM_WRAP : entity nx.NX_RAM_WRAP
            generic map(
                std_mode     => "NOECC_2kx24",
                mcka_edge    => '0',
                mckb_edge    => '0',
                pcka_edge    => '0',
                pckb_edge    => '0',
                pipe_ia      => '0',
                pipe_ib      => '0',
                pipe_oa      => '0',
                pipe_ob      => '0',
                mem_ctxt     => ""
            )
            port map(
                ACK  => clk,
                ACKD => '0',
                ACKR => '0',
                BCK  => clk,
                BCKD => '0',
                BCKR => '0',
                AI   => nx_di,
                BI   => (others => '0'),
                ACOR => open,
                AERR => open,
                BCOR => open,
                BERR => open,
                AO   => open,
                BO   => nx_do,
                AA   => nx_addr,
                ACS  => en,
                AWE  => we,
                AR   => '0',
                BA   => nx_addr,
                BCS  => en,
                BWE  => '0',
                BR   => '0'
            );

    end generate generate_nx_ram;

    generate_nx_rfb : if depth_memory <= 64 generate
        type ram_type is array (depth_memory - 1 downto 0) of std_logic_vector(15 downto 0);
        signal ram : ram_type := (others => (others => '0'));
    begin
        -- NX_RFB_WRAP version kept here while the Questa NX_RFB_M model issue is investigated.
        --
        -- signal nx_rfb_addr : std_logic_vector(5 downto 0);
        -- signal nx_rfb_do   : std_logic_vector(15 downto 0);
        --
        -- nx_rfb_addr(5 downto memory_add_size)    <= (others => '0');
        -- nx_rfb_addr(memory_add_size - 1 downto 0) <= addr;
        --
        -- do <= nx_rfb_do;
        --
        -- label_NX_RFB_WRAP : entity nx.NX_RFB_WRAP
        --     generic map(
        --         rck_edge  => '0',
        --         wck_edge  => '0',
        --         mem_ctxt  => ""
        --     )
        --     port map(
        --         RCK => clk,
        --         WCK => clk,
        --         I   => di,
        --         COR => open,
        --         ERR => open,
        --         O   => nx_rfb_do,
        --         RA  => nx_rfb_addr,
        --         RE  => en,
        --         WA  => nx_rfb_addr,
        --         WE  => we
        --     );

        label_ram : process(clk) is
        begin
            if rising_edge(clk) then
                if en = '1' then
                    if we = '1' then
                        ram(to_integer(unsigned(addr))) <= di;
                    end if;
                    do <= ram(to_integer(unsigned(addr)));
                end if;
            end if;
        end process label_ram;

    end generate generate_nx_rfb;

end syn;
