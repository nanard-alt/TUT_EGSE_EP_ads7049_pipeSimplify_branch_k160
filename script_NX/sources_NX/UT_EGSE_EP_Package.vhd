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
use work.UT_EGSE_EP_Utils.all;

package UT_EGSE_EP_Package is
    constant ads_7049_complex_clock : std_logic := '0';
    constant Detector_Number        : integer   := 7;
    constant Detector_Number_Width  : natural   := index_width(Detector_Number);
    constant Filter_Number          : integer   := 2;
    constant Filter_Number_Width    : natural   := 1;

    --  config_32x32 ------------------------------------------------------------------
    type Array_config_32x32_type is array (0 to 31) of signed(31 downto 0);
    -----------------------------------------------------------------------------------

    --  o_coef_fir  -------------------------------------------------------------------
    type Array_config_32x16_type is array (0 to 31) of signed(15 downto 0);
    type Array_Array_config_32x16_type is array (0 to Filter_Number - 1) of Array_config_32x16_type;
    type Array_Array_config_32x16_type_32x16_type is array (0 to Detector_Number - 1) of Array_Array_config_32x16_type;
    -----------------------------------------------------------------------------------

    --  o_standard_energy_threshold ---------------------------------------------------
    type Array_config_10x16_type is array (0 to 9) of signed(15 downto 0);
    type Array_Array_config_10x16_type is array (0 to Filter_Number - 1) of Array_config_10x16_type;
    type Array_Array_Array_config_10x16_type is array (0 to Detector_Number - 1) of Array_Array_config_10x16_type;
    ------------------------------------------------------------------------------------

    --  TH_rise / TH_fall by filter ---------------------------------------------------
    type Array_config_32stdx2_type is array (0 to Filter_Number - 1) of std_logic_vector(31 downto 0);
    type Array_Array_config_32stdx2_type is array (0 to 1) of Array_config_32stdx2_type;
    -----------------------------------------------------------------------------------

    --  FIFO/spectrum counters by detector --------------------------------------------
    type Array_config_32stdxDetector_Number_type is array (0 to Detector_Number - 1) of std_logic_vector(31 downto 0);
    -----------------------------------------------------------------------------------

    --  o_gain legacy 32-bit ----------------------------------------------------------
    type Array_config_32unsignedx2_type is array (0 to Filter_Number - 1) of unsigned(31 downto 0);
    type Array_Array_config_32stdxDetector_Number_type is array (0 to Detector_Number - 1) of Array_config_32unsignedx2_type;
    -----------------------------------------------------------------------------------

    --  o_gain -------------------------------------------------------------------------
    type Array_config_16unsignedx2_type is array (0 to Filter_Number - 1) of unsigned(15 downto 0);
    type Array_Array_config_16unsignedxDetector_Number_type is array (0 to Detector_Number - 1) of Array_config_16unsignedx2_type;
    -----------------------------------------------------------------------------------

    --  rd_data_count by filter/detector ----------------------------------------------
    type Array_config_11stdx2_type is array (0 to 1) of std_logic_vector(10 downto 0);
    type Array_config_11stdxDetector_Number_type is array (0 to Detector_Number - 1) of std_logic_vector(10 downto 0);
    type Array_config_10stdx2_type is array (0 to 1) of std_logic_vector(9 downto 0);
    -----------------------------------------------------------------------------------

    --  data_before_filter / data_after_energy_level ----------------------------------
    type Array_config_16signedx2_type is array (0 to Filter_Number - 1) of signed(15 downto 0);
    type Array_config_16signedxDetector_Number_type is array (0 to Detector_Number - 1) of signed(15 downto 0);
    -----------------------------------------------------------------------------------

    --  din_fifo_raw_data / spectrum numeric arrays -----------------------------------
    type Array_config_32unsignedxDetector_Number_type is array (0 to Detector_Number - 1) of unsigned(31 downto 0);
    type Array_config_32signedx2_type is array (0 to 1) of signed(31 downto 0);
    type Array_config_32signedxDetector_Number_type is array (0 to Detector_Number - 1) of signed(31 downto 0);
    -----------------------------------------------------------------------------------

    --  coef_fir legacy detector array ------------------------------------------------
    type Array_Array_config_32xDetector_Number_type is array (0 to Detector_Number - 1) of Array_config_32x16_type;
    -----------------------------------------------------------------------------------

    --  reg_config --------------------------------------------------------------------
    type Array_config_32stdx5_type is array (4 downto 0) of std_logic_vector(31 downto 0);
    type Array_config_32stdx8_type is array (7 downto 0) of std_logic_vector(31 downto 0);
    type Array_config_16stdx8_type is array (7 downto 0) of std_logic_vector(15 downto 0);
    -----------------------------------------------------------------------------------

    --  data_rx / data_rx_keeped ------------------------------------------------------
    type Array_config_12stdx2_type is array (0 to 1) of std_logic_vector(11 downto 0);
    type Array_config_12stdxDetector_Number_type is array (0 to Detector_Number - 1) of std_logic_vector(11 downto 0);
    type Array_config_16stdx2_type is array (0 to 1) of std_logic_vector(15 downto 0);
    type Array_config_16stdxDetector_Number_type is array (0 to Detector_Number - 1) of std_logic_vector(15 downto 0);
    -----------------------------------------------------------------------------------

    --    constant memory_add_size : integer := 10;
    --    constant depth_memory    : integer := 2**memory_add_size;

end package UT_EGSE_EP_Package;


