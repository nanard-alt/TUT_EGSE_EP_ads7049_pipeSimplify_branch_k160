--
-- This software is governed by the CeCILL license under French law
-- and abiding by the rules of distribution of free software.
-- You can use, modify and/or redistribute the software under the terms
-- of the CeCILL license as circulated by CEA, CNRS and Inria at:
-- http://www.cecill.info
--
-- See LICENSE.txt for the full license text.

package UT_EGSE_EP_Utils is
    function index_width(value : positive) return natural;
end package;

package body UT_EGSE_EP_Utils is
    function index_width(value : positive) return natural is
        variable width     : natural := 0;
        variable max_index : natural := value - 1;
    begin
        while max_index > 0 loop
            width     := width + 1;
            max_index := max_index / 2;
        end loop;

        if width = 0 then
            return 1;
        else
            return width;
        end if;
    end function;
end package body;

