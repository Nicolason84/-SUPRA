# SUPRA — TEST RECOVERY PREMATCH LOT 1.1

Date: 2026-07-27
Scope: Runtime Provider, Conversation Memory, filesystem scan, plugin registry

## EXISTE

- 'SUPRAProviderPluginRegistry' is the canonical provider-plugin registry.
- 'SUPRAPluginDiscovery' already owns builtin Ollama discovery.
- 'ConversationMemoryStore.findConversationFilesOffMain' is the canonical memory scan helper.
- Existing index and fingerprint filenames are explicitly excluded.
- Existing tests cover provider registration, memory import, index persistence and refresh.

## OBSOLÈTE

- No obsolete engine was found or removed.
- The assumption that discovery is always called before provider inspection was invalid for isolated tests.

## DUPLIQUÉ

- No provider, registry, memory store or Event Bus was created.
- Discovery and registry registration remain the same canonical services; registration is now idempotent by plugin identifier.

## INCOHÉRENT

- The plugin registry could be empty when a consumer accessed the fallback engine without application bootstrap.
- The recursive enumerator returned no candidates in the XCTest filesystem context.

## DETTE

- Existing Swift 6 concurrency warnings remain outside this recovery scope.
- Full runtime provider health checks remain environment-dependent.

## RISQUE

- Builtin provider registration now occurs at registry initialization, preserving discovery as an idempotent compatibility path.
- Memory scanning uses the Foundation subpath API to preserve recursive discovery while avoiding the failing enumerator path.
