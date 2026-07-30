# CHANGELOG_TEMPLATE.md

## CHANGELOG Format

### Header
```markdown
# SUPRA Change Log

## ALPHA-01 (2026-07-28)

## ALPHA-01.0.0 - 2026-07-28

### Added
### Changed
### Deprecated
### Fixed
### Removed
### Security
### Technical
```

## Entries Format

### Entry Structure
```markdown
### Release Type [Label]

- **Description** (Link to evidence if available)
- **Files**: path/to/file
- **Evidence**: Reference to ALPHA01_RELEASE_AUDIT.md:ISSUES
- **Impact**: BLOCKER/CRITICAL/MAJEUR/MINEUR/INFO
- **Approved by**: SUPRA-Architect, Governance, Quality Gate Lead
- **Date**: 2026-07-28
- **Validation**: xcodebuild 0, runtime launch PASS, tests PASSED
```

### Severity Levels

| Level | Meaning | Examples |
|-------|---------|----------|
| BLOCKER | Prevents functionality | Build failure, runtime crash |
| CRITICAL | Governance or integrity impact | Git attribution missing |
| MAJEUR | High-impact functionality | Data handling issue |
| MINEUR | Consistency or quality | Warning category |
| INFO | System or status | Log issue, artifact catalog |

## Entry Types

### Added
- New feature implementation
- New component
- New workflow
- New function
- New file

### Changed
- Existing feature modification
- Existing component update
- Existing workflow change
- Existing architecture
- Existing behavior

### Deprecated
- Feature marked for removal
- API deprecated
- Component phasing out

### Fixed
- Bug fix
- Security patch
- Performance improvement
- Documentation fix
- Migration issue

### Removed
- Feature removal
- Component decommission
- Workflow deletion
- API removal

### Security
- Security vulnerability fix
- Authentication improvement
- Authorization enhancement
- Security audit findings

### Technical
- Technical debt reduction
- Code cleanup
- Infrastructure improvement
- Tooling update
- Dependency update

## Change Types Classification

### ALPHA-01 Changes (Baseline)
**Scope**: Fixed set of changes documented
**Rules**:
- All ALPHA-01 changes must be in BASELINE_ISSUES.md
- Must have evidence in ALPHA01_RELEASE_AUDIT.md
- Must be signed by SUPRA-Builder
- Must be approved by Governance

### ALPHA-02 Changes (Manual)
**Scope**: New manual implementation features
**Rules**:
- Changes must be in ALPHA02_EXECUTION_PACKAGE.md
- Must have evidence in ALPHA02_EXECUTION_PACKAGE.md
- Must follow ALPHA-02 best practices
- Must be documented in RELEASE_NOTES_ALPHA01.md

## Entry Validation

### Validation Criteria
- **Evidence**: Must have evidence reference
- **Impact**: Must have impact level
- **Approval**: Must have approver list
- **Date**: Must have date
- **Validation**: Must have validation evidence
- **Documentation**: Must link to changelog entry

### Entry Format Compliance
```bash
# Compliance check
validate_changelog_entry() {
    local severity=$1
    local evidence=$2
    local approver=$3
    local date=$4
    
    if [[ -z $severity ]]; then
        echo "ERROR: Missing severity level"
        return 1
    fi
    
    if [[ -z $evidence ]]; then
        echo "ERROR: Missing evidence"
        return 1
    fi
    
    if [[ -z $approver ]]; then
        echo "ERROR: Missing approver"
        return 1
    fi
    
    if [[ -z $date ]]; then
        echo "ERROR: Missing date"
        return 1
    fi
}
```

## Entry Examples

### ALPHA-01 Example
```markdown
### Fizz Impact

- **Description**: Git attribution complete, baseline documentation established
- **Files**: ALPHA01_RELEASE_AUDIT.md, GIT_CLEANUP_PLAN.md
- **Evidence**: ALPHA01_RELEASE_AUDIT.md
- **Impact**: BLOCKER
- **Approved by**: SUPRA-Architect, Governance, Quality Gate Lead
- **Date**: 2026-07-28
- **Validation**: Git attribution complete, baseline certified
```

### ALPHA-02 Example
```markdown
### Fizz Impact

- **Description**: Runtime publication path debugging and correction
- **Files**: RUNTIME_STATUS.md, ALPHA02_EXECUTION_PACKAGE.md
- **Evidence**: ALPHA02_EXECUTION_PACKAGE.md
- **Impact**: MAJEUR
- **Approved by**: SUPRA-Architect, Governance, Runtime team
- **Date**: [Future Date]
- **Validation**: Runtime publication diagnosis, package validation
```

## Entry Classification

### ALPHA-01 Classification Rules
1. Read BASELINE_ISSUES.md
2. Classify by severity
3. Link to evidence
4. Mark as ALPHA-01 change

### ALPHA-02 Classification Rules
1. Read ALPHA02_EXECUTION_PACKAGE.md
2. Classify by impact
3. Link to evidence
4. Mark as ALPHA-02 change

## Entry Status

### Status Tracking
| Status | Meaning | Notes |
|--------|---------|-------|
| DRAFT | Entry in draft form | Not yet validated |
| PENDING | Entry marked but not implemented | Awaiting implementation |
| IMPLEMENTED | Entry implemented | Ready for release |
| RELEASED | Entry released | In release notes |
| WITHDRAWN | Entry withdrawn | No longer valid |

## Entry Archive

### Historical Entries
| Date | Version | Type | Description |
|------|---------|------|-------------|
| 2026-07-28 | ALPHA-01.0.0 | Fizz Impact | Git attribution and baseline |

## Entry Governance

### Entry Governance Rules
- SUPRA-Builder creates entries
- SUPRA-Architect validates
- Governance approves
- Quality Gate Lead confirms
- Documentation updated

### Entry Log
| Entry ID | Date | Description | Modified by | Approved by |
|----------|------|-------------|-------------|-------------|
| E-001 | 2026-07-28 | ALPHA-01 baseline | SUPRA-Builder | SUPRA-Architect |

## Entry Migration

### Migration Types
1. **Entry migration**: Move entries between versions
2. **Entry modification**: Update existing entries
3. **Entry deletion**: Remove entries

### Migration Example
```bash
# Example entry migration
migrate_entry() {
    local from_version=$1
    local to_version=$2
    local entry_id=$3
    
    echo "Migrating entry $entry_id from $from_version to $to_version"
    # Execute migration steps
    # Preserve evidence
    # Update references
}
```

## Entry Validation Script

```bash
#!/bin/bash

validate_changelog_entry() {
    local level=$1
    local evidence=$2
    local approver=$3
    local date=$4
    
    # Basic validation
    if [[ -z $level ]]; then
        echo "ERROR: Missing severity level"
        return 1
    fi
    
    if [[ -z $evidence ]]; then
        echo "ERROR: Missing evidence"
        return 1
    fi
    
    if [[ -z $approver ]]; then
        echo "ERROR: Missing approver"
        return 1
    fi
    
    if [[ -z $date ]]; then
        echo "ERROR: Missing date"
        return 1
    fi
}

# Validate all entries in changelogs
for changelog in CHANGELOG_*.md; do
    echo "Validating $changelog"
    validate_changelog_entry
    if [[ $? -ne 0 ]]; then
        echo "ERROR: $changelog validation failed"
        exit 1
    fi
    echo "SUCCESS: $changelog validated"
done
```

## Forbiden Actions

- Never skip entry validation
- Never create entries without evidence
- Never bypass entry approval
- Never document incomplete entries

## Entry Status Summary

### ALPHA-01 Status
| Entry Type | Status | Examples |
|------------|--------|----------|
| Base Integrity | ✅ | ALPHA-01 baseline |
| Build Pass | ✅ | xcodebuild 0 |
| Runtime Success | ⚠️ | Runtime data issues |
| Documentation | ✅ | BASELINE_ACTION_PLAN |
| Tests | ⚠️ | 113/FAIL complete |

### ALPHA-02 Status
| Entry Type | Status | Examples |
|------------|--------|----------|
| Runtime Publication | 🔄 | Runtime publication fix |
| Memory Integration | 🔄 | Memory integration |
| Bootstrap Debug | 🔄 | Bootstrap debugging |
| CI/CD Pipeline | 🔄 | Pipeline implementation |

## Ready For ALPHA-02

### Entry Requirements
1. **ALPHA01_RELEASE_AUDIT.md** - Base integrity entry
2. **GIT_CLEANUP_PLAN.md** - Cleanup entry
3. **AGENTS.md** - Agents entry
4. **GO_SUPRA_INSTALL.sh** - Script validation entry
5. **RELEASE_MANIFEST.json** - Manifest entry
6. **RELEASE_NOTES_ALPHA01.md** - Release notes entry
7. **CHANGELOG_ALPHA01.md** - Change log entry

All required entries are now documented and prepared. ALPHA-02 can launch directly.