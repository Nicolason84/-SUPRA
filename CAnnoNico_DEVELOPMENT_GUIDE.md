The CAnnoNico Development Guide provides comprehensive documentation for developing, extending, and maintaining CAnnoNico-related codebases within the SUPRA ecosystem. This guide captures the current implementation patterns, conventions, and best practices established through years of CAnnoNico evolution.

## Current Implementation Summary

The CAnnoNico system is a sophisticated decision-making and knowledge management framework with the following core components:

### Core Architecture
- **Identity Management**: `KnowledgeIdentity`, `CAnnoNicoObject`, and `KnowledgeIdentityRegistry`
- **Context Processing**: `MissionContext`, `KnowledgeContextEngine`, and `ContextEngine`
- **Integration Layer**: `CAnnoNicoIntegrationBridge`, `CAnnoNicoSnapshotStore`, and `CAnnoNicoSnapshotState`
- **Knowledge Kernel**: `NOVAKnowledgeKernel`, `KnowledgeExplorer`, and `KnowledgeGraph`
- **Adapters**: `CAnnoNicoAdapter`, `CAnnoNicoSourceReference`, and `CAnnoNicoIntegrationSnapshot`

### Key Data Structures
- **CAnnoNicoObject**: Core entity representing knowledge objects with fields: id, type, source, name, description, path, project, module, created, modified, tags, authority, identity, lineage, relations, metadata

### Processing Engines
- **MissionContext**: Mission preparation and object filtering based on requirements, keywords, and authority
- **KnowledgeContextEngine**: Semantic context processing with keyword extraction and relevance scoring
- **KnowledgeExplorer**: Graph-based knowledge discovery and query execution

## Development Standards

### Swift 6 Compliance

#### Concurrency
```swift
// All CAnnoNico actors use @MainActor for UI updates
@MainActor
final class CAnnoNicoSnapshotStore: ObservableObject {
    @Published var state: CAnnoNicoSnapshotState?
    var references: [CAnnoNicoSourceReference] { state?.references ?? [] }
    
    @MainActor
    func refresh() {
        // All UI updates must be on MainActor
    }
}

// Sendable protocols for cross-boundary communication
protocol CAnnoNicoAdapter: Sendable {
    static var adapterID: String { get }
    func snapshot() -> CAnnoNicoSourceReference
}

// Structured concurrency for async operations
func processAsyncData() async throws -> [CAnnoNicoObject] {
    await withTaskGroup(of: [CAnnoNicoObject].self) { group in
        // Parallel processing of data
    }
}
```

#### Memory Management
```swift
// Use value types for immutable data
struct CAnnoNicoSourceReference: Codable, Hashable, Sendable {
    let id: String
    let role: String
    let path: String?
    let state: CAnnoNicoIntegrationState
    let inputs: [String]
    let outputs: [String]
    let capabilities: [String]
}

// Use weak references for potential circular dependencies
class CAnnoNicoSnapshotStore {
    weak var parent: SomeParent?
    
    func cleanup() {
        parent = nil
    }
}
```

### Code Conventions

#### Naming Standards
```swift
// Constants and configuration
struct CAnnoNicoIntegrationState: String, Codable, Sendable {
    case recovered, unavailable, partial
}

// Enums for predefined values
enum CAnnoNicoType: String, Codable, CaseIterable, Identifiable {
    case workspace, directory, file
    case swift, python, javascript
    case mission, decision, evidence
}

// Variables for runtime-stateful properties
class CAnnoNicoSnapshotStore {
    @Published private(set) var state: CAnnoNicoSnapshotState?
    private var refreshTask: Task<Void, Never>?
}
```

#### Error Handling
```swift
enum CAnnoNicoError: Error {
    case integrationFailed(String)
    case snapshotInvalid
    case validationFailed(String)
}

func validate(_ reference: CAnnoNicoSourceReference) throws {
    guard reference.state == .recovered else {
        throw CAnnoNicoError.validationFailed("Source not recovered")
    }
}
```

### Integration Package Structure

#### Adapters Pattern
```swift
// All adapters follow this pattern
public struct VideoSwapAdapter: CAnnoNicoAdapter {
    public static let adapterID = "video.swap"
    private let sourcePath: String?
    
    public func snapshot() -> CAnnoNicoSourceReference {
        return CAnnoNicoSourceReference(
            id: Self.adapterID,
            role: "ROLE_NAME",
            path: sourcePath,
            state: exists ? .recovered : .unavailable,
            inputs: ["input1", "input2"],
            outputs: ["output1", "output2"],
            capabilities: ["cap1", "cap2"]
        )
    }
}
```

#### Integration Bridge
```swift
// Integration bridge manages all adapters
enum SUPRACAnnoNicoIntegration {
    static var pucheroSource: String {
        ensureResolved()
        return SUPRAEnvironmentResolver.shared.path(for: "pucheroRoot")
    }
    
    static func snapshot() -> CAnnoNicoIntegrationSnapshot {
        var refs: [CAnnoNicoSourceReference] = []
        
        if pucheroState == .resolved {
            refs.append(PucheroMemoryAdapter(sourcePath: pucheroSource).snapshot())
        }
        
        return CAnnoNicoIntegrationSnapshot(references: refs)
    }
}
```

### Testing Standards

#### Unit Testing
```swift
import XCTest

final class CAnnoNicoSnapshotStoreTests: XCTestCase {
    func testRefreshCreatesValidState() {
        let store = CAnnoNicoSnapshotStore()
        
        let state = store.refresh()
        
        XCTAssertNotNil(state.snapshot)
        XCTAssertFalse(state.isStale)
        XCTAssertGreaterThan(state.recoveredCount, 0)
    }
}
```

#### Integration Testing
```swift
func testIntegrationWithAllAdapters() async {
    let snapshot = SUPRACAnnoNicoIntegration.snapshot()
    
    XCTAssertFalse(snapshot.references.isEmpty)
    
    for reference in snapshot.references {
        XCTAssertNotNil(reference.id)
        XCTAssertNotNil(reference.role)
        XCTAssertNotNil(reference.state)
        XCTAssertFalse(reference.inputs.isEmpty)
        XCTAssertFalse(reference.outputs.isEmpty)
        XCTAssertFalse(reference.capabilities.isEmpty)
    }
}
```

### Deployment Considerations

#### Configuration
```swift
// Environment-based configuration
struct CAnnoNicoConfiguration {
    let pucheroRoot: String
    let nicoAppRoot: String
    let videoSwapRoot: String
    let ttl: TimeInterval
    
    static func fromEnvironment() -> CAnnoNicoConfiguration {
        return CAnnoNicoConfiguration(
            pucheroRoot: ProcessInfo.processInfo.environment["PICHERO_ROOT"] ?? "",
            nicoAppRoot: ProcessInfo.processInfo.environment["NICO_APP_ROOT"] ?? "",
            videoSwapRoot: ProcessInfo.processInfo.environment["VIDEO_SWAP_ROOT"] ?? "",
            ttl: TimeInterval(ProcessInfo.processInfo.environment["CANNONICO_TTL"] ?? "30") ?? 30
        )
    }
}
```

#### Performance Monitoring
```swift
extension CAnnoNicoSnapshotStore {
    var performanceMetrics: [String: Any] {
        [
            "stateAge": state?.age ?? 0,
            "isStale": state?.isStale ?? true,
            "refreshCount": refreshCount,
            "errorRate": errorRate
        ]
    }
}
```

## Extension Guidelines

### Adding New Adapters
1. Create new source path validation
2. Implement the `CAnnoNicoAdapter` protocol
3. Add to integration bridge's `snapshot()` method
4. Update documentation

### Modifying Core Structures
1. Ensure backward compatibility
2. Maintain Codable conformance
3. Update all integration points
4. Run comprehensive test suite

### Updating Integration
1. Add to `SUPRACAnnoNicoIntegration` enum
2. Implement resolver in `SUPRAEnvironmentResolver`
3. Update UI components to use new adapter
4. Test end-to-end integration

## Migration Path

For projects upgrading from previous CAnnoNico versions:

### Breaking Changes
- `CAnnoNicoType` conversion to newer formats
- `CAnnoNicoSourceReference` structure updates
- Integration snapshot structure changes

### Compatibility Layer
```swift
// Migration helpers for backward compatibility
extension CAnnoNicoSnapshotState {
    var legacyFormat: [String: Any] {
        return [
            "snapshotId": snapshot.generatedAt.timeIntervalSince1970,
            "recoveredCount": recoveredCount,
            "sourceCount": sourceCount,
            "isStale": isStale
        ]
    }
}
```

## Troubleshooting

### Common Issues
1. **Adapter Not Found**: Check environment variables and source paths
2. **State Not Updated**: Verify integration bridge is resolving environment
3. **Performance Issues**: Monitor TTL settings and refresh frequency

### Debugging Commands
```bash
// Check integration status
cat ~/.config/opencode/CAnnoNicoIntegration.log

// Validate configuration
debug-mode --cannnico-integration

// Monitor state changes
watch -n 1 "cat ~/.config/opencode/CAnnoNicoState.json"
```

## Future Enhancements

### Planned Features
- Enhanced validation frameworks
- Real-time synchronization
- Multi-modal adaptation capabilities
- Advanced analytics and reporting

### Research Areas
- Quantum-resistant cryptographic signatures
- Federated learning for adaptation
- Neural networks for context understanding
- Decentralized trust management

## Conclusion

The CAnnoNico Development Guide establishes a comprehensive framework for building robust, maintainable, and scalable CAnnoNico applications within the SUPRA ecosystem. By following these standards, developers can ensure consistency, reliability, and future-proofing of their CAnnoNico implementations while maintaining compatibility with the existing system architecture.
