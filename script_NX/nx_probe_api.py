#!/usr/bin/env python3
"""Probe the local NXpython API without creating a project.

Run from Ubuntu with:
    cd /media/sf_script_NX
    nxpython nx_probe_api.py
"""

import inspect
import os

from nx_config import TARGET_BOARD, TARGET_CHIP, TARGET_VARIANT


def main():
    print("NanoXplore target")
    print("  board  :", TARGET_BOARD)
    print("  variant:", TARGET_VARIANT)
    print("  chip   :", TARGET_CHIP)
    print()

    print("Environment")
    for key in ("NANOXPLORE_PREFIX", "NANOXPLORE_PROGRAM", "LM_LICENSE_FILE"):
        print("  %s=%s" % (key, os.environ.get(key, "")))
    print()

    try:
        from nxpython import *  # noqa: F401,F403
    except Exception as exc:
        print("ERROR: cannot import nxpython API:", exc)
        return 1

    namespace = globals()
    interesting = []
    needles = (
        "project",
        "Project",
        "create",
        "addFile",
        "addFiles",
        "Mapping",
        "Variant",
        "Chip",
        "Device",
        "Progress",
    )

    for name, value in sorted(namespace.items()):
        if any(needle.lower() in name.lower() for needle in needles):
            interesting.append((name, value))

    print("Interesting nxpython symbols")
    for name, value in interesting[:200]:
        try:
            signature = str(inspect.signature(value))
        except Exception:
            signature = ""
        print("  %-40s %s %s" % (name, type(value).__name__, signature))

    print()
    print("Next step: use the matching project/template class to create %s for %s." % (TARGET_BOARD, TARGET_VARIANT))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
