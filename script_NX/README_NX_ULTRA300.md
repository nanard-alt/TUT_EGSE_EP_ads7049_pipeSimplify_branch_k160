# TUT_EGSE_EP NanoXplore Ultra300 Work Area

This directory is the NanoXplore work copy.

## Target

- Board/family: ULTRA300
- Variant: NG-ULTRA
- Chip: NX2H300TSA
- Top entity: TUT_EGSE
- NX Design Suite validated locally: 23.5.0.5

## Ubuntu Commands

```bash
cd /media/sf_script_NX
nxpython nx_check_sources.py
nxpython nx_probe_api.py
nxpython nx_find_ram_examples.py
nxpython nx_create_project_ultra300.py
```

If the local NXpython installation expects the board name instead of the family
name:

```bash
nxpython nx_create_project_ultra300.py --variant ULTRA300
```

To launch synthesis after project creation:

```bash
nxpython nx_create_project_ultra300.py --synthesize
```

## VHDL Policy

Only edit VHDL files under:

```text
sources_NX
```

The original source directory must remain untouched.

## Current NX Adaptation

- Opal Kelly FrontPanel objects removed from the top level.
- `fifo_pipe_in_*` and `fifo_pipe_out_*` IP instances removed from the top level.
- `FSM_raw_data` removed from the NX source copy.
- Raw science and spectrum streams are now exposed directly on the top entity.
- `rams_sp_rf` is kept as inferred single-port RAM. For Ultra300, use NX reports and `addMappingDirective` after first synthesis to select `RAM`, `RF`, or `RAM_ECC`.

## Notes

NanoXplore documentation groups Ultra300 with the NG-ULTRA family. Local project templates may ask for `NG-ULTRA`, `ULTRA300`, `NX2H300TSA`, or a combination of these values.
