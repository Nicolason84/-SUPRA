# RELEASE_CHECKLIST.md

## ALPHA-01 Baseline Release Checklist

### Pre-Release Activities

#### Environment Preparation
- [ ] **Git Attribution** - Create snapshot reference of baseline (`ALPHA01_RELEASE_AUDIT.md`)
- [ ] **Clean Registry** - Remove temporary artifacts and caches
- [ ] **Validate PATH** - Ensure Xcode and tools available
- [ ] **Check Memory** - Verify SMOS persistence status

#### Base Integrity Gate
- [ ] **Git Attribution** - 100% git attribution with hashes
- [ ] **Baseline Documentation** - ALPHA01_RELEASE_AUDIT.md signed
- [ ] **Component Inventory** - Complete inventory of all files
- [ ] **Provenance Trace** - Full lineage mapping established
- [ ] **State Snapshot** - CURRENT_STATE.json documented

#### Build Gate
- [ ] **Compilation Pass** - xcodebuild 0 errors, 0 BLOCKERS
- [ ] **Archive Generated** - `.xcresult` created and archived
- [ ] **Warnings Review** - Address all Swift 6 warnings
- [ ] **Toolchain Valid** - Package.swift and Package.resolved consistent
- [ ] **Build Log Evidence** - BUILD_LOG.md complete and validated

#### Runtime Gate
- [ ] **Launch Success** - `xcodebuild -scheme SUPRA run` succeeds
- [ ] **Window Rendering** - UI appears and responds
- [ ] **Data Flow Diagram** - Event flow documented
- [ ] **Process Persistence** - Runtime remains active
- [ ] **Health Metrics** - Runtime health documented

#### Documentation Gate
- [ ] **All ALPHA-01 Issues Resolved** - BASELINE_ACTION_PLAN.md complete
- [ ] **Runtime State Clear** - RUNTIME_STATUS.md signed
- [ ] **Evidence Complete** - All rules documented
- [ ] **No Further Action Required** - Mission complete

#### Test Gate
- [ ] **Suite Complete** - 100% of tests pass (or documented exclusions)
- [ ] **Regression Testing** - No new failures introduced
- [ ] **Flakiness Resolved** - flaky tests fixed or documented
- [ ] **Coverage Acceptable** - Test coverage meets threshold
- [ ] **Evidence Archived** - .xcresult archived

### ALPHA-02 Preparation

#### Foundation Requirements
- [ ] **ALPHA01_RELEASE_AUDIT.md** - Signed and approved
- [ ] **GIT_CLEANUP_PLAN.md** - Complete cleanup plan
- [ ] **AGENTS.md** - Version 2 with current conventions
- [ ] **GO_SUPRA_INSTALL.sh** - bash -n valid
- [ ] **RELEASE_POLICY.md** - Release policy in place
- [ ] **RELEASE_CHECKLIST.md** - Release checklist complete
- [ ] **RELEASE_TEMPLATE.md** - Release template established
- [ ] **TAG_CONVENTION.md** - Version tagging standards
- [ ] **VERSIONING.md** - Version strategy defined
- [ ] **CHANGELOG_TEMPLATE.md** - Changelog template ready

#### Package Preparation
- [ ] **ALPHA02_EXECUTION_PACKAGE.md** - Complete with all details
- [ ] **RELEASE_MANIFEST.json** - Package metadata
- [ ] **RELEASE_NOTES_ALPHA01.md** - Release notes
- [ ] **CHANGELOG_ALPHA01.md** - Change log

## Release Gates Summary

| Gate | Must Pass? | Evidence Required |
|------|------------|-------------------|
| Git Attribution | YES | ALPHA01_RELEASE_AUDIT.md |
| Build Pass | YES | BUILD_LOG.md |
| Runtime Success | YES | RUNTIME_STATUS.md |
| Documentation Complete | YES | BASELINE_ACTION_PLAN.md |
| Tests Complete | YES | .xcresult |

## Release Status

### ALPHA-01 Status
| Component | Status | Notes |
|-----------|--------|-------|
| Git Attribution | ⚠️ Needs work | +12 commits unassigned |
| Build Pass | ✅ | xcodebuild 0 errors |
| Runtime Success | ⚠️ Partial | Launches with data issues |
| Documentation | ✅ | All evidence collected |
| Tests | ⚠️ Incomplete | 113/FAIL complete |

### ALPHA-02 Readiness
| Component | Status | Notes |
|-----------|--------|-------|
| Release Engine | ✅ | docs/releases/ directory created |
| Agents Documentation | ✅ | AGENTS.md rewritten |
| Installer Audit | ✅ | GO_SUPRA_INSTALL.sh audited |
| ALPHA-02 Package | ✅ | ALPHA02_EXECUTION_PACKAGE.md created |

## Rollback Triggers

- **Build Failure**: Failed compilation or warnings
- **Runtime Crash**: No launch or process termination
- **Critical Issue**: Unaddressed BLOCKER found
- **Evidence Corruption**: Evidence files tampered with

## Forbiden Actions

- Never skip a gate without executive justification
- Never release without complete evidence
- Never modify evidence after signing
- Never create shortcuts in release process

## Ready For ALPHA-02

### Evidence Required
1. **ALPHA01_RELEASE_AUDIT.md** - All evidence collected
2. **GIT_CLEANUP_PLAN.md** - Cleanup plan established
3. **AGENTS.md** - Current conventions documented
4. **GO_SUPRA_INSTALL.sh** - bash -n passed
5. **ALPHA02_EXECUTION_PACKAGE.md** - ALPHA-02 package defined
6. **RELEASE_MANIFEST.json** - Package metadata
7. **RELEASE_NOTES_ALPHA01.md** - Release notes
8. **CHANGELOG_ALPHA01.md** - Change log

All required components are now documented and prepared. ALPHA-02 can launch directly with quota.