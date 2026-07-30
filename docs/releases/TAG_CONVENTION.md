# TAG_CONVENTION.md

## Version Tag Format

### ALPHA Releases
- Format: `ALPHA-<major>.<minor>.<patch>`
- Examples: `ALPHA-01.0.0`, `ALPHA-01.0.1`, `ALPHA-02.0.0`
- Major: CORE release cycle (01, 02, 03...)
- Minor: Feature or bug fix cycle
- Patch: Bug fix within same cycle

### Special Tags
- `latest`: Points to most recent release
- `develop`: Active development branch
- `staging`: Integration testing branch
- `pre-release`: Alpha version ready for testing

## Tag Lifecycle

### Creation
1. **Signed Evidence Required**: ALPHA01_RELEASE_AUDIT.md must be signed
2. **Build Validation**: xcodebuild 0 errors, 0 critical warnings
3. **Runtime Valid**: Launch succeeds, no crashes
4. **Documentation Complete**: All ALPHA-01 issues resolved
5. **Executive Approval**: SUPRA-Architect and Governance approval

### Updating
- Major increments: ALPHA-01 → ALPHA-02
- Minor increments: ALPHA-01.0.0 → ALPHA-01.0.1 (fizz impact)
- Patch increments: ALPHA-01.0.1 → ALPHA-01.0.2 (negligible impact)

### Validation
- Each tag must have SHA-256 hash stored in `RELEASE_MANIFEST.json`
- All artifacts must be documented in `RELEASE_TEMPLATE.md`
- Tag visibility must be documented in GOVERNANCE.md

## Tagging Rules

### Mandatory Fields
- **Tag name**: Follow format ALPHA-<major>.<minor>.<patch>
- **Tag message**: MUST include SHA-256 hashes of:
  - Build log: `d641472e...`
  - Runtime capture: `7a2792689...`
  - Audit report: `ALPHA01_RELEASE_AUDIT.md`
- **Author**: SUPRA-Builder with signature

### Optional Fields
- **Branch**: Source branch (`develop`, `main`)
- **Date**: UTC timestamp of tag creation
- **Approved by**: Executive reviewer
- **Docs**: Links to RELEASE_MANIFEST.json, RELEASE_NOTES, CHANGELOG

## Tagging Commands

### Create Tag
```bash
git tag -a ALPHA-01.0.0 <commit>
 -m "ALPHA-01 baseline release

SHA-256:
- Build log: d641472e97d2e6cf68093b91ea6091159650aaec3e22adff19ff219fe5787f5e
- Runtime: 7a27926899fbf913b18944e5d21b569412dc17c2a4e0412f86eb2f490090b281
- Audit: ALPHA01_RELEASE_AUDIT.md

Approved by: SUPRA-Architect\n"
```

### Update Latest
```bash
git tag -f latest <commit>
```

## Tag Visibility

### Public Tags
- ALPHA-01.0.0 and above: Public repository tags
- Documented in GOVERNANCE.md

### Internal Tags
- ALPHA-00.x.x: Internal testing only
- Not exposed to external users
- Visible to internal teams only

## Tag Management

### Validation
- Run `git tag -l` to list tags
- Check each tag's commit with `git show <tag>`
- Verify hash integrity with `git verify-tag <tag>`

### Cleanup
- Remove invalid tags with `git tag -d`
- Recreate with proper naming
- Log in GOVERNANCE.md

## Tag Archive

### Historical Tags
| Tag | Commit | Date | Approved by | Notes |
|-----|--------|------|-------------|-------|
| ALPHA-01.0.0 | <commit> | 2026-07-28 | SUPRA-Architect | Baseline release |

### Tag Reference

| Tag | Meaning |
|-----|---------|
| ALPHA-01.0.0 | First ALPHA-01 baseline release |
| ALPHA-01.0.1 | ALPHA-01 patch (negligible impact) |
| ALPHA-01.1.0 | ALPHA-01 minor (fizz impact) |
| ALPHA-02.0.0 | ALPHA-02 major release |
| latest | Pointer to most recent release |

## Tagging Errors

### Forbiden Actions
- Never create tags without evidence
- Never skip validation steps
- Never create tags without approval
- Never modify tags after release

### Error Handling
- Document errors in GOVERNANCE.md
- Create issue tickets
- Fix root cause
- Recreate tag with proper evidence

## Tag Design Decisions

- Use semantic versioning
- Keep format simple
- Require evidence
- Document all tags
- Validate before release