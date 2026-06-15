-- Copyright (C) 2026 Bernard BERTRAND
--
-- This file is part of TUT_EGSE_EP.
--
-- This software is governed by the CeCILL license under French law
-- and abiding by the rules of distribution of free software.
-- You can use, modify and/or redistribute the software under the terms
-- of the CeCILL license as circulated by CEA, CNRS and Inria at:
-- http://www.cecill.info
--
-- See LICENSE.txt for the full license text.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Injection is
    port(
        reset                  : in  std_logic;
        i_clk_fast              : in  std_logic;
        --fifo
        i_continuous_injection : in  std_logic;
        o_pipe_in_rd_en        : out std_logic;
        i_pipe_in_empty        : in  std_logic;
        i_pipe_in_valid        : in  std_logic;
        i_pipe_in_dout         : in  signed(11 downto 0);
        --output injection
        o_injection_started    : out std_logic;
        o_data                 : out signed(11 downto 0);
        o_ready                : out std_logic
    );
end entity Injection;

architecture RTL of Injection is

    signal count            : unsigned(5 downto 0);
    signal count_wait_valid : unsigned(5 downto 0);
    signal pipe_in_rd_en    : std_logic;
    type state_type is (wait_sampling_time, wait_valid, generate_ready);
    signal state            : state_type;
    signal wait_one_cycle   : std_logic;

begin

    label_process_Injection : process(i_clk_fast, reset) is
    begin
        if reset = '1' then
            state <= wait_sampling_time;

            pipe_in_rd_en <= '0';

            count            <= (others => '0');
            count_wait_valid <= (others => '0');

            o_data              <= x"258";
            o_ready             <= '0';
            wait_one_cycle      <= '0';
            o_injection_started <= '0';

        elsif rising_edge(i_clk_fast) then
            case state is

                when wait_sampling_time =>

                    count <= count + 1;

                    if pipe_in_rd_en = '0' and i_pipe_in_empty = '0' and i_pipe_in_valid = '0' and To_integer(count) = 58 then

                        pipe_in_rd_en <= '1';
                        o_ready       <= '0';
                        state         <= wait_valid;
                        count         <= (others => '0');
                    else
                        if i_pipe_in_empty = '1' and To_integer(count) = 58 then -- (58 + 2)*1/60.10^6 = 1µs
                            state <= generate_ready;
                            count <= (others => '0');
                        else
                            pipe_in_rd_en <= '0';
                            o_ready       <= '0';
                        end if;
                    end if;

                when wait_valid =>

                    count_wait_valid <= count_wait_valid + 1;

                    if i_pipe_in_valid = '1' then
                        o_data              <= i_pipe_in_dout;
                        o_ready             <= '1'; -- ready have to work every To_integer(count) = 43 when empty = '1'
                        o_injection_started <= '1';
                        pipe_in_rd_en       <= '0';
                        count               <= (others => '0');
                        state               <= wait_sampling_time;
                    else
                        if count_wait_valid = 3 then
                            pipe_in_rd_en    <= '0';
                            o_ready          <= '0';
                            state            <= wait_sampling_time;
                            count_wait_valid <= (others => '0');
                        else
                            pipe_in_rd_en <= '0';
                            o_ready       <= '0';
                        end if;
                    end if;

                when generate_ready =>

                    wait_one_cycle <= not wait_one_cycle;

                    if wait_one_cycle = '1' and i_continuous_injection = '1' then
                        o_ready        <= '1';
                        pipe_in_rd_en  <= '0';
                        state          <= wait_sampling_time;
                        wait_one_cycle <= '0';
                    else
                        if wait_one_cycle = '1' and i_continuous_injection = '0' then
                            pipe_in_rd_en  <= '0';
                            state          <= wait_sampling_time;
                            wait_one_cycle <= '0';
                        end if;
                    end if;
            end case;
        end if;
    end process;

    o_pipe_in_rd_en <= pipe_in_rd_en;

    --    label_process_Injection : process(i_clk_fast, reset) is
    --    begin
    --        if reset = '1' then
    --
    --            pipe_in_rd_en <= '0';
    --
    --            count <= (others => '0');
    --
    --            o_data  <= (others => '0');
    --            o_ready <= '0';
    --
    --        elsif rising_edge(i_clk_fast) then
    --
    --            count <= count + 1;
    --
    --            if pipe_in_rd_en = '0' and i_pipe_in_empty = '0' and i_pipe_in_valid = '0' and To_integer(count) = 43 then
    --
    --                pipe_in_rd_en <= '1';
    --                o_ready       <= '0';
    --            else
    --                if i_pipe_in_valid = '1' then
    --                    o_data        <= i_pipe_in_dout;
    --                    o_ready       <= '1'; -- ready have to work every To_integer(count) = 43 when empty = '1'
    --                    pipe_in_rd_en <= '0';
    --                    count         <= (others => '0');
    --                else
    --                    pipe_in_rd_en <= '0';
    --                    o_ready       <= '0';
    --                end if;
    --            end if;
    --
    --        end if;
    --    end process;
    --
    --    o_pipe_in_rd_en <= pipe_in_rd_en;

end architecture RTL;
