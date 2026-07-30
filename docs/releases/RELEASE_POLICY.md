# RELEASE_POLICY.md

## Purpose

This document defines the release policy for SUPRA (ALPHA-01 baseline) to ensure systematic, repeatable releases for ALPHA-02 and beyond.

## Release Types

### Major Release (e.g., ALPHA-02)
- Trigger: New functionality development cycle
- Requires: Complete ALPHA-02 package documentation
- Evidence: ALPHA02_EXECUTION_PACKAGE.md and ALPHA01_RELEASE_AUDIT.md
- Certification: All ALPHA-01 baseline issues resolved

### Minor Release (Hotfix)
- Trigger: Critical blockers only
- Requires: Emergency documentation with ALPHA-01 evidence
- Evidence: JUSTIFICATION for functional deviation
- Certification: Maintain ALPHA-01 baseline integrity

## Release Gates

### Pre-Release Gates (All Must Pass)
1. **Base Integrity Gate** - Git attribution and baseline established
2. **Build Gate** - xcodebuild 0, 0 errors, 0 critical warnings
3. **Runtime Gate** - Minimal launch, zero crashes, no blocking errors
4. **Documentation Gate** - All ALPHA-01 issues addressed
5. **Test Gate** - 100% test suite completion or documented exclusions

### Post-Release Gates
- All ALPHA-02 components fully tested
- Runtime stable (no timeout, no crashes)
- All functional requirements met

## Evidence Requirements

Each release must include:
- Signed ALPHA01_RELEASE_AUDIT.md
- complete GIT_CLEANUP_PLAN.md
- validated AGENTS.md (V2)
- correct GO_SUPRA_INSTALL.sh (bash -n valid)
- comprehensive ALPHA02_EXECUTION_PACKAGE.md
- complete RELEASE_MANIFEST.json
- RELEASE_NOTES_ALPHA01.md
- CHANGELOG_ALPHA01.md

## Responsibility

**SUPRA-Builder** is responsible for all release creation and documentation.

**Governance** must approve:
- Baseline Git snapshot
- Evidence collection
- Release decisions

## Rollback Policy

- **Immediate Rollback**: If launch fails
- **Partial Rollback**: If component fails
- **Complete Rollback**: If runtime becomes unstable
- All rollbacks must be documented in release notes

## Forbiden Actions

- Never release with unresolved BLOCKERS
- Never skip test gates
- Never modify environment or runtime without evidence
- Never release ALPHA-02 before baseline is fully documented

## Release Gates Summary

| Gate | Requirement | Evidence |
|------|-------------|----------|
| 1. Base Integrity | Git attribution complete | ALPHA01_RELEASE_AUDIT.md |
| 2. Build | xcodebuild 0, 0 errors | BUILD_LOG.md |
| 3. Runtime | Launch, no crashes | RUNTIME_STATUS.md |
| 4. Documentation | All issues resolved | BASELINE_ACTION_PLAN.md |
| 5. Test | Suite complete or documented | .xcresult archive |

## Release Status

### ALPHA-01 Status
- ✅ **READY FOR ALPHA-02**
- ✅ **BASELINE DOCUMENTED**
- ✅ **PROOF EVIDENCE COLLECTED**
- ⚠️ **GIT BASELINE NEEDS ATTRIBUTION**
- ⚠️ **RUNTIME REQUIRES PUBLICATION DATA**
- ⚠️ **BLAZE SWEEPS NOT CERTIFIED**

### ALPHA-02 Readiness
- **0% complete** - awaiting manual implementation
- **Full preparation required** - all preparation files now in place
- **READY FOR DEVELOPMENT** - infrastructure established