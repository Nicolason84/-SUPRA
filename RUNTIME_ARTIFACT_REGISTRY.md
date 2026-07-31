# RUNTIME ARTIFACT REGISTRY

Foundation Era V1 — Runtime Certification
Generated: 2026-07-31

## Artifact Classification

Every Runtime artifact is classified into exactly one category:

### DOCUMENTATION
Artifacts that describe the project, build configuration, or system state.

| Name | Type | Owner | Producer | Consumer | Canonical Location | Persistence | Creation Trigger |
|------|------|-------|----------|----------|-------------------|-------------|-----------------|
| BUILD_STATUS.md | Documentation | Build System | xcodebuild (SUCCEEDED) | Runtime, Developers | Workspace root | Permanent | Build completion |
| CONTINUITY.md | Documentation | ContinuityManager | Continuity load() | Runtime, Developers | Workspace root | Permanent | Manual/Generated |
| NEXT_MISSION.md | Documentation | ContinuityManager | Continuity load() | Runtime, Developers | Workspace root | Permanent | Manual/Generated |
| EXECUTIVE_STARTUP_PIPELINE.md | Documentation | Executive | Manual | Developers | Workspace root | Permanent | Manual |

### RUNTIME STATE
Artifacts that store the current Runtime state and must be initialized or restored at each boot.

| Name | Type | Owner | Producer | Consumer | Canonical Location | Persistence | Creation Trigger |
|------|------|-------|----------|----------|-------------------|-------------|-----------------|
| SUPRA_STATE.json | Runtime State | ContinuityManager | loadSupraState() | Runtime | Workspace root (also Application Support) | Persistent | First boot / Restore |
| RUNTIME_STATUS.json | Runtime State | RuntimeDiagnostics | loadRuntimeStatus() | Runtime | Application Support/State | Persistent | First boot / Restore |
| RUNTIME_STATUS.md | Runtime State | RuntimeMonitor | loadRuntimeStatus() | Runtime | Workspace root | Persistent | First boot / Restore |
| runtime_diagnostics.json | Runtime State | SUPRARuntimeKernel | loadRuntimeDiagnostics() | Runtime | Application Support/Root | Persistent | First boot / Restore |
| version.json | Runtime State | RuntimeInitializer | loadVersionJSON() | Runtime | Application Support/State | Persistent | First boot / Restore |
| ESTATE_STATE.json | Runtime State | EstateManager | Estate initialization | Runtime | Workspace root | Persistent | First boot / Restore |

### RUNTIME REGISTRY
Artifacts that register and catalogue Runtime components, capabilities, and dependencies.

| Name | Type | Owner | Producer | Consumer | Canonical Location | Persistence | Creation Trigger |
|------|------|-------|----------|----------|-------------------|-------------|-----------------|
| PROJECT_REGISTRY.json | Registry | ProjectRegistry | Runtime initialization | Runtime, Discovery | Workspace root | Persistent | First boot / Restore |
| INDEX.json | Registry | ArchitectureIndex | Indexing phase | Runtime, Dashboard | Workspace root | Persistent | First boot / Restore |
| MANIFEST.json | Registry | ManifestBuilder | Manifest generation | Runtime, Discovery | Workspace root | Persistent | First boot / Restore |
| LOT1_INSTALLATION_PROOF.json | Registry | InstallationVerifier | Installation verification | Runtime | proofs/ directory | Persistent | First boot / Restore |
| LOT2_INSTALLATION_PROOF.json | Registry | InstallationVerifier | Installation verification | Runtime | proofs/ directory | Persistent | First boot / Restore |
| LOT3_INSTALLATION_PROOF.json | Registry | InstallationVerifier | Installation verification | Runtime | proofs/ directory | Persistent | First boot / Restore |
| ARTIFACT_REGISTRY.json | Registry | ArtifactReader | Artifact discovery | Runtime | Runtime Storage | Persistent | First boot / Restore |

### CACHE
Artifacts that store regenerated or cached data and can be safely rebuilt.

| Name | Type | Owner | Producer | Consumer | Canonical Location | Persistence | Creation Trigger |
|------|------|-------|----------|----------|-------------------|-------------|-----------------|
| SUPRA_RUNTIME_GRAPH.json | Cache | RuntimeGraph | Graph generation | Runtime | Workspace root | Ephemeral | On-demand regeneration |
| Runtime diagnostic caches | Cache | RuntimeDiagnostics | Diagnostic collection | Runtime | Application Support/Cache | Ephemeral | On demand |

### GENERATED ARTIFACT
Artifacts that are produced by build, test, or execution processes.

| Name | Type | Owner | Producer | Consumer | Canonical Location | Persistence | Creation Trigger |
|------|------|-------|----------|----------|-------------------|-------------|-----------------|
| .xcresult files | Generated | xcodebuild | Test execution | Test Reports | Artifacts/ directory | Temporary | Test execution |
| Test result bundles | Generated | xcodebuild | Test execution | Developers | Artifacts/ directory | Temporary | Test execution |
| .supra_reports/* | Generated | SUPRA pipeline | Pipeline execution | Developers | .supra_reports/ | Temporary | Pipeline execution |

### SESSION ARTIFACT
Artifacts that are ephemeral and exist only for the duration of a Runtime session.

| Name | Type | Owner | Producer | Consumer | Canonical Location | Persistence | Creation Trigger |
|------|------|-------|----------|----------|-------------------|-------------|-----------------|
| Runtime event logs | Session | SUPRARuntimeLogger | Runtime events | Diagnostics | Application Support/Logs | Session only | Runtime active |
| Phoenix boot probe data | Session | PhoenixBoot | Network probe | Runtime | Application Support/Cache | Session only | Runtime boot |
| In-memory state snapshots | Session | RuntimeKernel | State management | Runtime | Memory | Session only | Runtime active |