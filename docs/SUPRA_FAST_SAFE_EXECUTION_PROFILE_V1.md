# SUPRA FAST SAFE EXECUTION PROFILE V1

DATE=2026-09-21
AUTHORITY=NICOLAS
PURPOSE=MAXIMIZE_MACHINE_THROUGHPUT_WITHOUT_WEAKENING_HUMAN_GATES

## EXECUTION PROFILE

EXECUTION_PROFILE=FAST_SAFE
MAX_PARALLEL_WORKERS=3
USE_EXISTING_GABRIEL_CONDUCTOR=YES
BATCH_EVIDENCE_READS=YES
PREFETCH_NEXT_SAFE_PHASE=YES
NO_WAIT_FOR_UI=YES
NO_RESCAN_IF_FRESH_EVIDENCE_EXISTS=YES
CACHE_AND_REUSE_PROVEN_EVIDENCE=YES
MERGE_DUPLICATE_READS=YES
FAIL_FAST_ON_REAL_BLOCKER=YES

## AUTO-EXECUTE ENVELOPE

AUTO_EXECUTE_READ_ONLY=YES
AUTO_EXECUTE_REVERSIBLE_LOCAL=YES
AUTO_EXECUTE_ISOLATED_BRANCH_CHANGES=YES
AUTO_EXECUTE_BUILD_TEST_COMPARE=YES
AUTO_EXECUTE_NONDESTRUCTIVE_REGISTRY_UPDATE=YES
AUTO_EXECUTE_EXISTING_SERVICE_RESTART=YES
AUTO_EXECUTE_EVIDENCE_INDEXING=YES
AUTO_EXECUTE_MEMORY_RETURN=YES
AUTO_EXECUTE_CANONICAL_PROPOSAL=YES

## ALWAYS HUMAN-GATED

MONEY_MOVEMENT=HUMAN_GATE
LEGAL_ADMIN_SUBMISSION=HUMAN_GATE
PUBLIC_EXTERNAL_SEND=HUMAN_GATE
SIGNATURE_BINDING_COMMITMENT=HUMAN_GATE
DESTRUCTIVE_DELETE_OR_PURGE=HUMAN_GATE
SECURITY_PERMISSION_CHANGE=HUMAN_GATE
AUTHORITY_CHANGE=HUMAN_GATE
PRODUCTION_MUTATION_WITHOUT_ROLLBACK=HUMAN_GATE

## HUMAN GATE REDUCTION LAW

Do not stop merely because an action changes local code or internal state.

If the action is:
- reversible,
- isolated or rollbackable,
- observable,
- evidence-returning,
- within existing authority,

then continue automatically.

If a blocker can be solved by:
- reading more evidence,
- building/testing,
- comparing alternatives,
- retrying an existing service,
- using an existing worker,
- generating a proposal,
- performing a reversible local implementation,

the machine must resolve it without asking Nicolas.

## PARALLELISM LAW

Parallelize independent read-only/reversible work up to 3 workers.

Never parallelize:
- conflicting writes to the same canonical owner,
- money movement,
- authority changes,
- legal/admin submissions,
- external publication,
- destructive operations.

One canonical writer remains authoritative.

## PREFETCH LAW

While phase N executes:
- prefetch evidence for N+1 when read-only,
- prepare candidate analyses,
- do not promote N+1 until N passes.

## ACCEPTANCE

Faster execution is valid only if:
- evidence quality is unchanged or improved,
- rollback remains available,
- human gates remain intact,
- memory/canon return remains complete,
- no duplicate engine/bridge/runtime is created.
