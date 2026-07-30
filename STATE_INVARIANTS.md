# State Invariants

The Executive Runtime now enforces these invariants in the canonical runtime loop:

1. Exactly one active state exists at a time through the local `activeState` tracker.
2. The first legal state is `BOOT`.
3. Every subsequent state must be authorized by `SUPRARuntimeLoop.isTransitionAllowed(from:to:)`.
4. Every recorded transition carries authorization proof in `producedEvidence`.
5. Illegal transitions are classified as failure conditions.
6. Every mission iteration ends in either `READY` or `FAILED`.
7. `READY` is reachable only through `FREEZE`.
8. Validation is bounded and cannot wait indefinitely.
9. Mission execution is bounded and cannot wait indefinitely.
10. Learning writes to `WorkspaceMemoryStore` before `FREEZE`.
11. One next executive mission is produced before `READY`.
12. Focused tests assert the canonical transition chain and absence of root cause on the success path.
