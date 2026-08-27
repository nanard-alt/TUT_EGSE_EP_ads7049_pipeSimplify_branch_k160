library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity config_fifo is
    generic (
        DATA_WIDTH : positive := 32;
        DEPTH      : positive := 1024;
        ADDR_WIDTH : positive := 10
    );
    port (
        i_wr_clk        : in  std_logic;
        i_rd_clk        : in  std_logic;
        i_reset         : in  std_logic;
        i_wr_en         : in  std_logic;
        i_din           : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        o_full          : out std_logic;
        i_rd_en         : in  std_logic;
        o_dout          : out std_logic_vector(DATA_WIDTH - 1 downto 0);
        o_empty         : out std_logic;
        o_valid         : out std_logic;
        o_rd_data_count : out std_logic_vector(ADDR_WIDTH - 1 downto 0)
    );
end entity config_fifo;

architecture RTL of config_fifo is
    subtype ptr_type is unsigned(ADDR_WIDTH downto 0);
    type ram_type is array (0 to DEPTH - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);

    signal ram              : ram_type;
    signal wr_ptr_bin       : ptr_type;
    signal wr_ptr_gray      : ptr_type;
    signal wr_ptr_gray_next : ptr_type;
    signal rd_ptr_bin       : ptr_type;
    signal rd_ptr_gray      : ptr_type;
    signal rd_ptr_gray_next : ptr_type;

    signal rd_ptr_gray_wr_meta : ptr_type;
    signal rd_ptr_gray_wr_sync : ptr_type;
    signal wr_ptr_gray_rd_meta : ptr_type;
    signal wr_ptr_gray_rd_sync : ptr_type;

    signal full_reg  : std_logic;
    signal empty_reg : std_logic;
    signal dout_reg  : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal valid_reg : std_logic;

    function bin_to_gray(bin_value : ptr_type) return ptr_type is
    begin
        return bin_value xor ('0' & bin_value(bin_value'high downto 1));
    end function;

    function gray_to_bin(gray_value : ptr_type) return ptr_type is
        variable bin_value : ptr_type;
    begin
        bin_value(bin_value'high) := gray_value(gray_value'high);
        for i in gray_value'high - 1 downto 0 loop
            bin_value(i) := bin_value(i + 1) xor gray_value(i);
        end loop;
        return bin_value;
    end function;

    function used_count(wr_gray : ptr_type; rd_bin : ptr_type) return std_logic_vector is
        variable count_value : ptr_type;
    begin
        count_value := gray_to_bin(wr_gray) - rd_bin;
        return std_logic_vector(count_value(ADDR_WIDTH - 1 downto 0));
    end function;
begin

    write_side : process(i_wr_clk, i_reset) is
        variable wr_ptr_next : ptr_type;
    begin
        if i_reset = '1' then
            wr_ptr_bin          <= (others => '0');
            wr_ptr_gray         <= (others => '0');
            rd_ptr_gray_wr_meta <= (others => '0');
            rd_ptr_gray_wr_sync <= (others => '0');
            full_reg            <= '0';

        elsif rising_edge(i_wr_clk) then
            rd_ptr_gray_wr_meta <= rd_ptr_gray;
            rd_ptr_gray_wr_sync <= rd_ptr_gray_wr_meta;

            wr_ptr_next := wr_ptr_bin;

            if i_wr_en = '1' and full_reg = '0' then
                ram(to_integer(wr_ptr_bin(ADDR_WIDTH - 1 downto 0))) <= i_din;
                wr_ptr_next := wr_ptr_bin + 1;
            end if;

            wr_ptr_bin       <= wr_ptr_next;
            wr_ptr_gray      <= bin_to_gray(wr_ptr_next);
            wr_ptr_gray_next <= bin_to_gray(wr_ptr_next);

            if bin_to_gray(wr_ptr_next)(ADDR_WIDTH downto ADDR_WIDTH - 1) = not rd_ptr_gray_wr_sync(ADDR_WIDTH downto ADDR_WIDTH - 1) and
               bin_to_gray(wr_ptr_next)(ADDR_WIDTH - 2 downto 0) = rd_ptr_gray_wr_sync(ADDR_WIDTH - 2 downto 0) then
                full_reg <= '1';
            else
                full_reg <= '0';
            end if;
        end if;
    end process write_side;

    read_side : process(i_rd_clk, i_reset) is
        variable rd_ptr_next : ptr_type;
    begin
        if i_reset = '1' then
            rd_ptr_bin          <= (others => '0');
            rd_ptr_gray         <= (others => '0');
            wr_ptr_gray_rd_meta <= (others => '0');
            wr_ptr_gray_rd_sync <= (others => '0');
            empty_reg           <= '1';
            dout_reg            <= (others => '0');
            valid_reg           <= '0';

        elsif rising_edge(i_rd_clk) then
            wr_ptr_gray_rd_meta <= wr_ptr_gray;
            wr_ptr_gray_rd_sync <= wr_ptr_gray_rd_meta;

            valid_reg  <= '0';
            rd_ptr_next := rd_ptr_bin;

            if i_rd_en = '1' and empty_reg = '0' then
                dout_reg    <= ram(to_integer(rd_ptr_bin(ADDR_WIDTH - 1 downto 0)));
                valid_reg   <= '1';
                rd_ptr_next := rd_ptr_bin + 1;
            end if;

            rd_ptr_bin       <= rd_ptr_next;
            rd_ptr_gray      <= bin_to_gray(rd_ptr_next);
            rd_ptr_gray_next <= bin_to_gray(rd_ptr_next);

            if bin_to_gray(rd_ptr_next) = wr_ptr_gray_rd_sync then
                empty_reg <= '1';
            else
                empty_reg <= '0';
            end if;
        end if;
    end process read_side;

    o_dout          <= dout_reg;
    o_valid         <= valid_reg;
    o_full          <= full_reg;
    o_empty         <= empty_reg;
    o_rd_data_count <= used_count(wr_ptr_gray_rd_sync, rd_ptr_bin);

end architecture RTL;
