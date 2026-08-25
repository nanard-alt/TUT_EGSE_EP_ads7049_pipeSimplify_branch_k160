#!/usr/bin/env python3
"""Create the first NanoXplore Ultra300 project from sources_NX.

Run from Ubuntu with:
    cd /media/sf_script_NX
    nxpython nx_create_project_ultra300.py

Useful variants while we confirm the exact local Ultra300 name:
    nxpython nx_create_project_ultra300.py --variant ULTRA300
    nxpython nx_create_project_ultra300.py --variant NG-ULTRA
"""

from pathlib import Path
import argparse
import shutil
import sys

from nx_config import (
    DEFAULT_CLOCK_NAME,
    PROJECT_NAME,
    ROOT,
    SOURCE_LIST,
    SOURCES_DIR,
    TARGET_BOARD,
    TARGET_CHIP,
    TARGET_VARIANT,
    TOP_CELL_LIB,
    TOP_CELL_NAME,
)

from nxpython import *  # noqa: F401,F403


def parse_args():
    parser = argparse.ArgumentParser(description="Create NanoXplore Ultra300 project")
    parser.add_argument("--variant", default=TARGET_VARIANT, help="NX variant name, for example NG-ULTRA or ULTRA300")
    parser.add_argument("--package", default=None, help="NX package name, for example BGA-484")
    parser.add_argument("--project-dir", default=str(ROOT / PROJECT_NAME), help="Output project directory")
    parser.add_argument("--top-lib", default=TOP_CELL_LIB, help="Top cell library")
    parser.add_argument("--top", default=TOP_CELL_NAME, help="Top cell entity name")
    parser.add_argument("--clock-name", default=DEFAULT_CLOCK_NAME, help="Top clock port/net name")
    parser.add_argument("--clock-period-ns", type=float, default=50.0, help="Clock period in ns, default 50 ns = 20 MHz")
    parser.add_argument("--synthesize", action="store_true", help="Run project.synthesize() after creation")
    parser.add_argument("--place", action="store_true", help="Run project.place() after synthesis")
    parser.add_argument("--route", action="store_true", help="Run project.route() after place")
    parser.add_argument("--clean", action="store_true", help="Remove the project directory before creating it")
    return parser.parse_args()


def read_ordered_sources():
    if not SOURCE_LIST.exists():
        raise RuntimeError("Missing %s. Run nxpython nx_check_sources.py first." % SOURCE_LIST)

    files = []
    for line in SOURCE_LIST.read_text().splitlines():
        item = line.strip()
        if not item:
            continue

        path = Path(item)
        if not path.exists():
            # nx_sources_order.f can be generated on Windows. Rebuild the path
            # relative to sources_NX when running inside Ubuntu /media/sf_script_NX.
            try:
                rel = Path(item.replace("\\", "/").split("sources_NX/", 1)[1])
            except IndexError:
                rel = Path(path.name)
            path = SOURCES_DIR / rel

        if not path.exists():
            raise RuntimeError("Missing VHDL source: %s" % path)
        files.append(path)
    return files


def main():
    args = parse_args()
    project_dir = Path(args.project_dir).resolve()

    if args.clean and project_dir.exists():
        shutil.rmtree(str(project_dir))

    project_dir.mkdir(parents=True, exist_ok=True)
    sources = read_ordered_sources()

    print("Creating NanoXplore project")
    print("  board   :", TARGET_BOARD)
    print("  chip    :", TARGET_CHIP)
    print("  variant :", args.variant)
    if args.package:
        print("  package :", args.package)
    print("  top     : %s.%s" % (args.top_lib, args.top))
    print("  clock   : %s, %.3f ns" % (args.clock_name, args.clock_period_ns))
    print("  dir     :", project_dir)
    print("  files   :", len(sources))

    project = createProject(str(project_dir))

    # Project setup.
    if args.package:
        try:
            project.setVariantName(args.variant, args.package)
        except TypeError:
            raise RuntimeError("This nxpython version does not accept a package argument in setVariantName(): %s" % args.package)
    else:
        project.setVariantName(args.variant)
    project.setTopCellName(args.top_lib, args.top)

    # Add VHDL files in deterministic dependency order.
    for source in sources:
        project.addFile("work", str(source))

    # First timing constraint. Adjust --clock-period-ns when the Ultra300 board
    # clock frequency is confirmed.
    project.createClock(
        target="getClockNet(%s)" % args.clock_name,
        name=args.clock_name,
        period=args.clock_period_ns,
    )

    project.save(str(project_dir / (PROJECT_NAME + "_created.nym")))

    if args.synthesize or args.place or args.route:
        print("Running synthesis")
        project.synthesize()
        project.save(str(project_dir / (PROJECT_NAME + "_synthesized.nym")))

    if args.place or args.route:
        print("Running place")
        project.place()
        project.save(str(project_dir / (PROJECT_NAME + "_placed.nym")))

    if args.route:
        print("Running route")
        project.route()
        project.save(str(project_dir / (PROJECT_NAME + "_routed.nym")))
        project.save(str(project_dir / (PROJECT_NAME + "_routed.vhd")))

    print("Done")
    return 0


if __name__ == "__main__":
    sys.exit(main())
