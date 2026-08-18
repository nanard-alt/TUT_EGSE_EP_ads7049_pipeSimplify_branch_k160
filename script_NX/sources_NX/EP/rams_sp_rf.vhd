-- Single-port RAM, read-first behaviour.
--
-- NanoXplore note:
-- Keep this memory inferred in RTL. NX Design Suite can then map it to RF,
-- RAM or RAM_ECC with NXpython mapping directives after synthesis analysis.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
    type ram_type is array (depth_memory-1 downto 0) of std_logic_vector(15 downto 0);
    signal ram : ram_type;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' then
                if we = '1' then
                    ram(to_integer(unsigned(addr))) <= di;
                end if;
                do <= ram(to_integer(unsigned(addr)));
            end if;
        end if;
    end process;

end syn;
