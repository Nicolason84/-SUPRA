# VERSIONING.md

## SUPRA Versioning Strategy

### Core Principle
- Follow semantic versioning (MAJOR.MINOR.PATCH)
- Prepend ALPHA for developmental releases
- Document all changes in CHANGELOG_<VERSION>.md

## Version Components

### MAJOR (First Number)
- Increments when:
  - New functional feature added
  - BREAKING API changes
  - Runtime architecture modification
- Examples: ALPHA-01.0.0, ALPHA-01.1.0, ALPHA-02.0.0

### MINOR (Second Number)
- Increments when:
  - Non-breaking feature addition
  - Enhanced capability
  - New dependency integration
- Examples: ALPHA-01.0.0 → ALPHA-01.0.1 (fizz impact)

### PATCH (Third Number)
- Increments when:
  - Bug fix
  - Security patch
  - Performance improvement
  - Documentation fix
- Examples: ALPHA-01.0.0 → ALPHA-01.0.1 (negligible impact)

## Version Type Classification

### ALPHA Releases (Development)
| Version Type | Impact | Examples | Documentation Requirement |
|--------------|--------|----------|---------------------------|
| ALPHA-01.0.0 | Core NEW FUNCTIONALITY | First baseline release | Full documentation |
| ALPHA-01.0.1 | Negligible Impact | Bug fix, security patch | Limited documentation |
| ALPHA-01.1.0 | Fizz Impact | New feature, non-breaking | Medium documentation |

### Public Releases (Post-Development)
- Same semantic versioning but without ALPHA prefix
- Examples: 1.0.0, 1.1.0

## Version Status

### Pre-Release Stagnation
- Version stuck at ALPHA-01.x.x until:
  - Git attribution complete
  - ALPHA-01 baseline certified
  - ALPHA-01 issues resolved

### Version Gates
- **ALPHA-01 Readiness**: ALPHA-01 baseline completed
- **ALPHA-02 Preparation**: Ready for manual implementation
- **Development Maturity**: ALPHA-02.x.x for ALPHA-02 cycle

## Version Matrix

| Status | ALPHA-01 Release | ALPHA-02 Release | Notes |
|--------|------------------|------------------|-------|
| Current | ✅ ALPHA-01.0.0 | 🔄 ALPHA-02.x.x | Ready for manual |
| Ready for Release | ✅ | 🚫 | All evidence collected |
| Development | 🚫 | ✅ ALPHA-02.0.0 | Manual implementation |

## Version Validation

### Validation Criteria
- **Evidence**: All changes documented
- **Approval**: Executive review
- **Testing**: Full functional testing
- **Compatibility**: Backward compatible

### Version Prevention

```bash
# Never allow development versions in production
if [[ $VERSION =~ ^ALPHA ]]; then
    echo "ERROR: ALPHA version detected in production"
    exit 1
fi
```

## Version Rollback

### Rollback Rules
- **PATCH rollback**: Acceptable if minimal impact
- **MINOR rollback**: Documentation required
- **MAJOR rollback**: Executive approval required

### Rollback Documentation
- Document reason in CHANGELOG_VERSIONING.md
- Create issue ticket
- Log in GOVERNANCE.md
- Notify all stakeholders

## Version Tracking

### Files to Track
- CHANGELOG_<version>.md
- ALPHA01_RELEASE_AUDIT.md
- RELEASE_MANIFEST.json
- RELEASE_NOTES_<version>.md

### Historical Tracking
| Version | Commit | Date | Author | Approved by |
|---------|--------|------|--------|-------------|
| ALPHA-01.0.0 | <commit> | 2026-07-28 | SUPRA-Builder | SUPRA-Architect |

## Version Decision Log

### Version Decision Registry
| Decision ID | Date | Description | Impact | Approved by |
|-------------|------|-------------|--------|-------------|
| V-001 | 2026-07-28 | ALPHA-01.0.0 baseline | Core functionality | SUPRA-Architect |

### Version Freeze

#### ALPHA-01 Freeze
- Version: ALPHA-01.0.0
- Status: Frozen and documented
- Branch: develop (legacy)
- Changes: BLOCKED until ALPHA-02

#### ALPHA-02 Development
- Version: ALPHA-02.x.x
- Status: Manual implementation (when quota returns)
- Branch: develop (new)
- Changes: Manual feature development

## Version Migration

### Migration Types
1. **Direct upgrade**: ALPHA-01.0.0 → ALPHA-02.0.0
2. **Skip version**: ALPHA-01.0.0 → ALPHA-02.0.0 (ALPHA-01.1.0 skipped)
3. **Patch upgrade**: ALPHA-01.0.0 → ALPHA-01.0.1

### Migration Planning
```bash
# Migration script
migrate_version() {
    local from=$1
    local to=$2
    echo "Migrating from $from to $to"
    # Execute migration steps
    # Update dependencies
    # Update configuration
    # Update documentation
}
```

## Version Compliance

### Compliance Checklist
- [ ] Version follows semantic versioning
- [ ] ALPHA prefix for development releases
- [ ] Documentation complete
- [ ] Testing complete
- [ ] Evidence collected
- [ ] Executive approval
- [ ] Stakeholder notification

## Version Governance

### Approving Versions
- SUPRA-Architect: Technical review
- Governance: Business approval
- Quality Gate Lead: Testing validation

### Version Monitoring
- Track version compliance daily
- Monitor for version errors
- Archive version history
- Update version registry

## Forbiden Actions

- Never modify established version numbers without evidence
- Never skip version validation
- Never document incomplete versions
- Never bypass approval for critical version changes