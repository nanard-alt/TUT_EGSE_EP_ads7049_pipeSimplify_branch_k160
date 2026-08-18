# check_nanoxplore.py
import sys
import os

print("Python executable:", sys.executable)
print("Python version:", sys.version)
print("PATH:", os.environ.get("PATH", ""))
print("NANOXPLORE variables:")
for key, value in sorted(os.environ.items()):
    if "NX" in key.upper() or "NANO" in key.upper() or "LICENSE" in key.upper():
        print(f"{key}={value}")