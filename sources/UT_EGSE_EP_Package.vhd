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

package UT_EGSE_EP_Package is

    constant ads_7049_complex_clock : std_logic := '0';
    constant Detector_Number        : integer   := 4;
    constant Detector_Number_Width  : natural   := 2;
    constant Filter_Number          : integer   := 2;
    constant Filter_Number_Width    : natural   := 1;
    constant Enable_ADC_Driver      : boolean   := true;

    type Array_config_32x32_type is array (0 to 31) of signed(31 downto 0);

    type Array_config_32x16_type is array (0 to 31) of signed(15 downto 0);
    type Array_Array_config_32x16_type is array (0 to Filter_Number - 1) of Array_config_32x16_type;
    type Array_Array_config_32x16_type_32x16_type is array (0 to Detector_Number - 1) of Array_Array_config_32x16_type;

    type Array_config_32stdx2_type is array (0 to Filter_Number - 1) of std_logic_vector(31 downto 0);

    type Array_config_32stdxDetector_Number_type is array (0 to Detector_Number - 1) of std_logic_vector(31 downto 0);
    type Array_Array_config_32stdx2_type is array (0 to 1) of Array_config_32stdx2_type;
    type Array_config_32unsignedx2_type is array (0 to Filter_Number - 1) of unsigned(31 downto 0);
    type Array_Array_config_32stdxDetector_Number_type is array (0 to Detector_Number - 1) of Array_config_32unsignedx2_type;

    type Array_config_11stdx2_type is array (0 to 1) of std_logic_vector(10 downto 0);
    type Array_config_11stdxDetector_Number_type is array (0 to Detector_Number - 1) of std_logic_vector(10 downto 0);
    type Array_config_10stdx2_type is array (0 to 1) of std_logic_vector(9 downto 0);
    type Array_config_16signedx2_type is array (0 to Filter_Number - 1) of signed(15 downto 0);
    type Array_config_16signedxDetector_Number_type is array (0 to Detector_Number - 1) of signed(15 downto 0);

    type Array_config_32unsignedxDetector_Number_type is array (0 to Detector_Number - 1) of unsigned(31 downto 0);
    type Array_config_32signedx2_type is array (0 to 1) of signed(31 downto 0);
    type Array_config_32signedxDetector_Number_type is array (0 to Detector_Number - 1) of signed(31 downto 0);

    type Array_Array_config_32xDetector_Number_type is array (0 to Detector_Number - 1) of Array_config_32x16_type;
    type Array_config_32stdx5_type is array (4 downto 0) of std_logic_vector(31 downto 0);
    type Array_config_32stdx8_type is array (7 downto 0) of std_logic_vector(31 downto 0);

    type Array_config_12stdx2_type is array (0 to 1) of std_logic_vector(11 downto 0);
    type Array_config_12stdxDetector_Number_type is array (0 to Detector_Number - 1) of std_logic_vector(11 downto 0);
    type Array_config_16stdx2_type is array (0 to 1) of std_logic_vector(15 downto 0);
    type Array_config_16stdxDetector_Number_type is array (0 to Detector_Number - 1) of std_logic_vector(15 downto 0);

    --    constant memory_add_size : integer := 10;
    --    constant depth_memory    : integer := 2**memory_add_size;

end package UT_EGSE_EP_Package;
