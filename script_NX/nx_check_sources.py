#!/usr/bin/env python3
"""Check the NanoXplore VHDL source copy and write a deterministic file list.

Run from Ubuntu with:
    cd /media/sf_script_NX
    nxpython nx_check_sources.py
"""

from pathlib import Path
import re
import sys

from nx_config import SOURCE_LIST, SOURCES_DIR, TARGET_BOARD, TARGET_CHIP, TARGET_VARIANT

SRC = SOURCES_DIR
OUT = SOURCE_LIST

SOURCE_ORDER = [
    "UT_EGSE_EP_Utils.vhd",
    "UT_EGSE_EP_Package.vhd",
    "CDC/Fast_to_Slow_CDC.vhd",
    "CDC/Fast_to_Slow_CDC_lite.vhd",
    "EP/rams_sp_rf.vhd",
    "EP/FIR_filter.vhd",
    "EP/gain.vhd",
    "EP/Energy_level.vhd",
    "EP/detect_standard_energy.vhd",
    "EP/spectrum_FSM.vhd",
    "EP/spectrum.vhd",
    "EP/cycle_spectrum.vhd",
    "EP/EP.vhd",
    "Interface/Injection.vhd",
    "Interface/FSM_read_config.vhd",
    "ADC/Rx_fe_ads7049_and.vhd",
    "DAC/DAC121S101_Driver.vhd",
    "DAC/remote_DAC121S01_driver.vhd",
    "DAC/Top_DAC121S101_Driver.vhd",
    "TOP/TUT_EGSE.vhd",
]

FORBIDDEN_ACTIVE_PATTERNS = [
    "FRONTPANEL",
    "okHost",
    "okWireIn",
    "okWireOut",
    "okPipeIn",
    "okPipeOut",
    "fifo_pipe_in",
    "fifo_pipe_out",
    "FSM_raw_data",
    "raw_data_fifo_k160",
    "clk_wiz_0_k160",
    "UNISIM",
]


def active_lines(path):
    for lineno, line in enumerate(path.read_text(errors="replace").splitlines(), 1):
        if not re.match(r"\s*--", line):
            yield lineno, line


def rel(path):
    return path.relative_to(SRC).as_posix()


def main():
    if not SRC.exists():
        print("ERROR: sources_NX not found:", SRC)
        return 2

    errors = []
    warnings = []
    entities = {}
    references = {}

    for path in sorted(SRC.rglob("*.vhd")):
        text = path.read_text(errors="replace")
        for match in re.finditer(r"(?im)^\s*entity\s+(\w+)\s+is", text):
            entities[match.group(1)] = rel(path)

        for lineno, line in active_lines(path):
            ref = re.search(r":\s*entity\s+work\.(\w+)", line, re.I)
            if ref:
                references.setdefault(ref.group(1), []).append((rel(path), lineno))

            for pattern in FORBIDDEN_ACTIVE_PATTERNS:
                if pattern.lower() in line.lower():
                    errors.append("%s:%d: forbidden active pattern '%s'" % (rel(path), lineno, pattern))

    for item in SOURCE_ORDER:
        if not (SRC / item).exists():
            errors.append("missing required source: %s" % item)

    for name, locations in sorted(references.items()):
        if name not in entities:
            locs = ", ".join("%s:%d" % loc for loc in locations)
            errors.append("missing referenced entity %s <- %s" % (name, locs))

    with OUT.open("w", newline="\n") as stream:
        for item in SOURCE_ORDER:
            stream.write((SRC / item).as_posix() + "\n")

    print("NX source directory:", SRC)
    print("Written file list:", OUT)
    print("Target board:", TARGET_BOARD)
    print("Target variant:", TARGET_VARIANT)
    print("Target chip:", TARGET_CHIP)
    print("Defined entities:", len(entities))
    print("Referenced work entities:", len(references))

    if warnings:
        print("\nWarnings:")
        for warning in warnings:
            print("  -", warning)

    if errors:
        print("\nErrors:")
        for error in errors:
            print("  -", error)
        return 1

    print("\nOK: VHDL copy is ready for the first NanoXplore project script pass.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

