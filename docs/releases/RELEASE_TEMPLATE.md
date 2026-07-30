# RELEASE_TEMPLATE.md

# Release Manifest

## Release Information
- **Version**:
- **Tag**:
- **Commit**:
- **Date**:

## Artifact List

| Type | Path | SHA-256 | Size | Purpose |
|------|------|---------|------|----------|
| Application | SUPRA.app | | | Main application |
| Build Log | BUILD_LOG.md | | | Compilation evidence |
| Runtime Capture | RUNTIME_STATUS.md | | | Launch evidence |
| Audit Report | ALPHA01_RELEASE_AUDIT.md | | | Final audit |
| Cleanup Plan | GIT_CLEANUP_PLAN.md | | | Repository cleanup |
| Documentation | docs/releases/ | | | Release documentation |
| Manifest | RELEASE_MANIFEST.json | | | Package metadata |

## Component Dependencies

### Executive Layer
- **BOOT.md** - Executive bootstrap protocol
- **EXECUTIVE_BOOTSTRAP_V2** - Workflow orchestrator

### Runtime Layer
- **Runtime API** - Node.js backend (1082 lignes)
- **CAnnoNico pipeline** - Backend orchestrator

### Memory Layer
- **SMOS** - Memory Operating System (smos/)
- **Canonical records** - Unique canonical forms

### Knowledge Layer
- **World Engine** - Cognitive engines
- **Event Protocol** - Event coordination

## Component Status

| Component | Baseline | ALPHA-02 Readiness | Status |
|-----------|----------|-------------------|--------|
| SwiftUI Application | operational | Ready for ALPHA-02 | ✅ |
