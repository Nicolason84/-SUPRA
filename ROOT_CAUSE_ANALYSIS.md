# SUPRA — ROOT CAUSE ANALYSIS LOT 1.1

## Provider fallback test

Call path: test → SUPRAFallbackEngine.shared → SUPRAProviderPluginRegistry.shared → providerPlugins.

The registry was empty unless SUPRAPluginDiscovery.discoverAll() had already been called by an application bootstrap path. The isolated test does not start that UI bootstrap. The failure was therefore an initialization contract gap, not a missing provider.

Minimal correction: seed the registry with the existing builtin SUPRAOllamaProvider at registry initialization and make subsequent registration idempotent by plugin identifier.

## Memory index exclusion and unchanged file tests

Call path: test fixture writes files → ConversationMemoryStore.findConversationFilesOffMain(directory).

The existing FileManager enumerator returned no usable candidates in the XCTest temporary-directory context. Consequently valid JSON files were not returned, while index exclusion assertions could not complete.

Minimal correction: use Foundation subpathsOfDirectory as the canonical recursive filesystem enumeration for this helper, retaining the explicit index and fingerprint exclusions.

## Concurrency and cache assessment

- Failures reproduced deterministically.
- No evidence of a race, shared mutable cache, or timing dependency was observed.
- Provider state was an initialization-order issue.
- Memory state was a filesystem enumeration API issue.
