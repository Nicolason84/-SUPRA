# FACTORY_03_RUNTIME — Specification V1

## Mission

Maintain executable production.

## Responsibility

Ensure the system compiles, links, and executes correctly. Apply minimal patches to fix runtime issues. Roll back on failure. Validate runtime behaviour.

## Owner

SUPRA-Runtime / SUPRA-Builder

## Inputs

| Input | Source | Format |
|-------|--------|--------|
| Source code | Repository | Swift files |
| Architecture map | FACTORY_01 | ARCHITECTURE_MAP.md |
| Discovery report | FACTORY_02 | DISCOVERY_REPORT.md |
| Build configuration | Package.swift, Xcode project | Swift PM |
| Previous build status | Build logs | Log files |

## Outputs

| Output | Format | Description |
|--------|--------|-------------|
| PATCH_REPORT.md | Markdown | Record of all patches applied |
| BUILD_REPORT.md | Markdown | Build results: success/failure, warnings, errors |
| VALIDATION_REPORT.md | Markdown | Runtime validation results |

## Gates

### INPUT Gate
- FACTORY_01 and FACTORY_02 outputs are certified
- Build tools are available (Xcode, Swift)
- Source code compiles (or compilation errors are documented)

### EXECUTION Gate
- Patch strategy is documented
- Rollback plan exists
- Build configuration is known

### OUTPUT Gate
- Build succeeds (or failures are documented with root cause)
- Runtime validation passes
- All patches are reversible
- Build artifacts are reproducible

## Quality Criteria

1. **Build**: Zero compilation errors (warnings documented)
2. **Runtime**: All critical paths execute without crash
3. **Patches**: Every patch has a documented rationale and rollback
4. **Reproducibility**: Build is byte-for-byte reproducible

## Templates

See `templates/` directory for output artefact templates.

## Automation

See `gates/` directory for gate validation scripts.
