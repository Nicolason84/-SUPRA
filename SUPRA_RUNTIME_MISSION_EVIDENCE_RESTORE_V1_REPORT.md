# SUPRA_RUNTIME_MISSION_EVIDENCE_RESTORE_V1

Status: PASS

## Rule

`SUPRAMissionEvidenceLoader.loadRequiredEvidence()` loads:

- `GRAPH_SCHEMA_PROBE` from `~/NOVA_OS/SUPRA_STREAM_RECONCILIATION_V1/PROBES`
- `STATUS` from `~/NOVA_OS/SUPRA_ACTION_CENTER_V1/ACTION_RUNS/*probe-project-graph*`
  or `~/NOVA_OS/SUPRA_STREAM_RECONCILIATION_V1/RUNS`

`SUPRAExecutiveStore.sendChat()` rejects a request when either evidence ID is
missing.

## Canonical sources

### GRAPH_SCHEMA_PROBE

Source:

`/Users/nicolasalonso/NOVA_OS/SUPRA_STREAM_RECONCILIATION_V1/PROBES/20260720_182104/GRAPH_SCHEMA_PROBE.json`

SHA-256:

`0c36088224d1cb1ea993b9a6775710c554fd98562b5c07eda0cc7cb4223373fb`

Integrity:

- Valid JSON
- Schema: `SUPRA_PROJECT_GRAPH_SCHEMA_PROBE_V1`
- Status: `PASS`
- `graph_mutation`: `false`

### STATUS

Source:

`/Users/nicolasalonso/NOVA_OS/SUPRA_STREAM_RECONCILIATION_V1/RUNS/20260720_105622/STATUS.json`

SHA-256:

`cec41332e1a607f744ae85b62a566b05912f5fccb4813e080f1782eb6f595343`

Integrity:

- Valid JSON
- Schema: `SUPRA_STREAM_RECONCILE_PROJECTS_PRODUCTS_V3`
- Status: `PASS`
- `source_mutation`: `false`
- `supra_app_mutation`: `false`

## Restoration

The sandboxed SUPRA process resolves its home directory under:

`/Users/nicolasalonso/Library/Containers/com.nicolasalonso.SUPRA/Data`

Both target files were absent before restoration. The canonical files were
copied without transformation to the equivalent paths under that sandbox home.
Source and restored SHA-256 hashes are identical.

No SUPRA Chat source file was modified.

## Validation

- `GET http://127.0.0.1:18765/v1/health`: `PASS`
- Provider: `OLLAMA`
- Model: `qwen3:4b`
- ASK prompt response: `ASK_RESTORED_OK`
- PLAN prompt response: `PLAN_RESTORED_OK`
- SUPRA Chat runtime badge: `Connected`
- SUPRA Chat execution state: `Success`

Visual proof:

`SUPRA_RUNTIME_MISSION_EVIDENCE_RESTORE_V1_PROOF.png`
