#!/usr/bin/env python3
"""Find NanoXplore RAM inference/IP examples in the local NX installation.

Run from Ubuntu with:
    cd /media/sf_script_NX
    nxpython nx_find_ram_examples.py
"""

from pathlib import Path
import os

from nx_config import TARGET_BOARD, TARGET_CHIP, TARGET_VARIANT


KEYWORDS = (
    "MemInfer",
    "RAM_ECC",
    "addMappingDirective",
    "addRAMLocation",
    "memory",
    "RAM",
)


def candidate_roots():
    env_prefix = os.environ.get("NANOXPLORE_PREFIX")
    if env_prefix:
        yield Path(env_prefix)

    for root in (
        "/opt/NanoXplore/Impulse/nxdesignsuite-23.5.0.5",
        "/opt/NanoXplore",
    ):
        yield Path(root)


def main():
    seen = set()
    hits = []

    print("Target board:", TARGET_BOARD)
    print("Target variant:", TARGET_VARIANT)
    print("Target chip:", TARGET_CHIP)
    print()

    for root in candidate_roots():
        if not root.exists() or root in seen:
            continue
        seen.add(root)
        print("Searching:", root)

        for path in root.rglob("*"):
            if not path.is_file():
                continue
            if path.suffix.lower() not in (".py", ".vhd", ".vhdl", ".txt", ".md", ".rst", ".pdf"):
                continue

            name_hit = any(key.lower() in path.name.lower() for key in KEYWORDS)
            text_hit = False
            if path.suffix.lower() != ".pdf":
                try:
                    text = path.read_text(errors="ignore")
                except Exception:
                    text = ""
                text_hit = any(key in text for key in KEYWORDS)

            if name_hit or text_hit:
                hits.append(path)

    print("\nRAM-related local files:")
    for path in hits[:200]:
        print(path)

    if not hits:
        print("No local RAM examples found. We will keep inferred RTL RAM and use NX reports/mapping directives after the first synthesis.")
    else:
        print("\nNext step: inspect the most relevant MemInfer or RAM_ECC example before choosing an explicit NX RAM/IP mapping.")


if __name__ == "__main__":
    main()
