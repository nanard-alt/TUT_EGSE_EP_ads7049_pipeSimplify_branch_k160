"""Shared configuration for the NanoXplore Ultra300 project scripts."""

from pathlib import Path


ROOT = Path(__file__).resolve().parent
SOURCES_DIR = ROOT / "sources_NX"
SOURCE_LIST = ROOT / "nx_sources_order.f"

PROJECT_NAME = "TUT_EGSE_EP_ultra300"
TOP_CELL_NAME = "TUT_EGSE"
TOP_CELL_LIB = "work"

# NanoXplore documentation groups Ultra300 with the NG-ULTRA family/variant.
# Keep the exact chip/package selection centralized because local templates may
# expect either a variant name, a chip name, or both.
TARGET_BOARD = "ULTRA300"
TARGET_VARIANT = "NG-ULTRA"
TARGET_CHIP = "NX2H300TSA"

DEFAULT_CLOCK_NAME = "i_sys_clk"

