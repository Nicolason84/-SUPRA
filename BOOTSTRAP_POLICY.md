# Bootstrap Policy

Date: July 29, 2026

- `SUPRACompositionRoot` is the unique bootstrap creator and binder of governed services.
- No governed service may access `SUPRACompositionRoot.shared`.
- No governed peer may be resolved through `.shared` inside `init()`.
- No business logic is allowed inside `init()`.
- Runtime activation is forbidden during construction.
- Observers depending on late-bound services must start only after explicit binding.
- Every governed dependency must be injected or explicitly bound.
- The bootstrap dependency graph must remain acyclic.
- The runtime activation sequence must remain deterministic: `CREATE_SERVICES -> BIND_DEPENDENCIES -> PUBLISH_REFERENCES -> ACTIVATE_RUNTIME -> RUNTIME_READY`.
