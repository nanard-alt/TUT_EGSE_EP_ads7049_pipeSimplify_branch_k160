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

------------------------------------------------------------------------------------------------------------
-- Driver for DAC121S101 12-bit Digital-to-Analog Converter

-- The on-chip output amplifier allows rail-to-rail output swing and the three wire serial interface operates
-- at clock rates up to 30 MHz over the specified supply voltage range and is compatible with standard SPI.

-- The supply voltage (VA) for the DAC121S101 serves as its voltage reference, providing the widest possible output
-- dynamic range, from 2.7 V to 3.6 V, +3.3 V is chosen in DORN project.

-- Data is clocked into the 16-bit shift register on the falling edges of SCLK after the fall of SYNC_n.

-- When the frame synchronization input goes low, it enables the input shift register and data is transferred on
-- the falling edges of SCLK. The DAC is updated on the 16th clock cycle unless SYNC_n is brought high before the 16th
-- clock, in which case the rising edge of SYNC_n acts as an interrupt and the write sequence is ignored by the DAC.

-- Since the SYNC_n and DIN buffers draw more current when they are high, they must be idled low between write
-- sequences to minimize power consumption.
-- Minimum power consumption is achieved in the power-down mode with SCLK disabled and SYNC and DIN idled low.
-- The time to exit power-down (Wake-Up Time) is typically tWU = 39us.

-- VOUT = VA * (Data_Reg / 4096) with Data_Reg at any value between 0 and 4095.

-- Input shift register:
-- B15 - B14 - B13 - B12 - B11 - ... - B0
--  X     X    PD1   PD2   D11 - ... - D0
------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DAC121S101_Driver is
    port(
        -- Reset and Clock
        i_Rst_n      : in  std_logic;             -- General Reset, negative polarity
        i_Clk        : in  std_logic;             -- State Machine clock, FSM_freq = 2*Converting_freq
        -- Control
        i_Start      : in  std_logic;             -- Start converting
        o_Busy       : out std_logic;             -- Busy flag when data register is converted
        i_Num_Data   : in  std_logic_vector(11 downto 0); -- Input data register to convert
        -- DAC SPI
        o_DAC_SCLK   : out std_logic;             -- SPI Serial Clock
        o_DAC_SYNC_n : out std_logic;             -- SPI Frame synchronization input, negative polariry
        o_DAC_DIN    : out std_logic              -- SPI Master Output Slave Input (MOSI)
    );
end entity DAC121S101_Driver;

architecture RTL of DAC121S101_Driver is

    -- State Machine
    type state_type is (S_Idle, S_Synchronization, S_Writing, S_Tranferring);
    signal state : state_type;

    -- DAC Control Registers
    signal SPI_Bit_Number_cnt : unsigned(3 downto 0); -- 16-bit standard SPI protocol, MSB first
    signal SPI_Sent_Data      : std_logic_vector(11 downto 0); -- 12-bit unsigned data
    
    

begin

    p_DAC_SPI_Protocol : process(i_Rst_n, i_Clk)
    begin
        if i_Rst_n = '0' then
            o_Busy             <= '0';            -- DAC not in operation
            o_DAC_SCLK         <= '1';            -- No clock
            o_DAC_SYNC_n       <= '1';            -- Chip not synchronized
            o_DAC_DIN          <= '0';            -- No data sent
            SPI_Bit_Number_cnt <= (others => '1'); -- Send MSB first, init at max
            SPI_Sent_Data      <= (others => '0'); -- Empty buffer
            state              <= S_Idle;         -- Start in idle state
        elsif rising_edge(i_Clk) then
            -- FSM
            case state is                         -- FSM_freq = 2 * Conversion_freq
                when S_Idle =>
                    -- Internal registers initialization
                    SPI_Bit_Number_cnt <= (others => '1'); -- Send MSB first, init at max
                    SPI_Sent_Data      <= (others => '0'); -- Empty buffer

                    -- Outputs initialization
                    o_Busy       <= '0';          -- Not busy
                    o_DAC_SCLK   <= '1';          -- No clock
                    o_DAC_SYNC_n <= '1';          -- Chip not synchronized
                    o_DAC_DIN    <= '0';          -- No data sent

                    -- Wait for the start flag
                    if i_Start = '1' then
                        SPI_Sent_Data <= i_Num_Data; -- Save input data to send on serial register
                        o_Busy        <= '1';     -- DAC has started operations
                        state         <= S_Synchronization;
                    end if;
                ----------------------------------------------------------------------------------
                when S_Synchronization =>
                    o_DAC_SCLK <= '0';            -- Synchronize on clock low
                    state      <= S_Writing;      -- Enter in writing state after synchronization
                ----------------------------------------------------------------------------------
                when S_Writing =>
                    o_DAC_SCLK   <= '1';          -- Write on clock high
                    o_DAC_SYNC_n <= '0';          -- Chip synchronized on falling edge

                    -- Send Control register bit on SPI Bus, MSB first
                    if SPI_Bit_Number_cnt(3 downto 2) = "11" then -- Four first cycles
                        o_DAC_DIN <= '0';         -- SPI-Bits #15-14-13-12 are always set at zero
                    else                          -- Normal operations
                        o_DAC_DIN     <= SPI_Sent_Data(11);
                        SPI_Sent_Data <= SPI_Sent_Data(10 downto 0) & "0"; -- Fill with zero
                    end if;
                    state <= S_Tranferring;
                ----------------------------------------------------------------------------------
                when S_Tranferring =>
                    o_DAC_SCLK <= '0';            -- Transfer on clock low

                    -- Bits are sent in descending order from bit #15 to bit #0
                    SPI_Bit_Number_cnt <= SPI_Bit_Number_cnt - 1;

                    -- Check if end of conversion
                    if SPI_Bit_Number_cnt = X"0" then -- End of transfer
                        state <= S_Idle;          -- All 16 bits have been sent, return to idle state
                    else
                        state <= S_Writing;       -- Some bits are still not sent
                    end if;
                ----------------------------------------------------------------------------------
                when others =>
                    state <= S_Idle;
            end case;
        end if;
    end process p_DAC_SPI_Protocol;

end architecture RTL;
