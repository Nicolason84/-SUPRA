# SUPRA — FAILURE MATRIX LOT 1.1

| Test | Initial 1× | Initial 5× | Cause | Corrected 1× | Corrected 10× | Corrected 25× |
|---|---:|---:|---|---:|---:|---:|
| SUPRARuntimeProviderProofTests.testFallbackScenario | FAIL | 5/5 FAIL | Empty plugin registry before discovery bootstrap | PASS | 10/10 PASS | 25/25 PASS |
| SUPRAConversationMemoryAsyncTests.testINDEX_FILE_EXCLUDED_FROM_SCAN | FAIL | 5/5 FAIL | Enumerator returned no candidates in XCTest filesystem context | PASS | 10/10 PASS | 25/25 PASS |
| SUPRAConversationMemoryAsyncTests.testUNCHANGED_FILES_NOT_REPARSED | FAIL | 5/5 FAIL | Same filesystem enumeration failure | PASS | 10/10 PASS | 25/25 PASS |

Classification: deterministic, reproducible, not intermittent.
