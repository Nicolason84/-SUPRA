# SYSTEM TOPOLOGY — V1

## Status: CERTIFIED

| Property | Value |
|----------|-------|
| **Version** | SYS_TOPOLOGY_V1 |
| **Date** | 2026-07-29 |
| **Authority** | FACTORY_01_ARCHITECTURE |
| **Certified By** | FACTORY_06_PROOF |

---

## 1. RUNTIME TOPOLOGY

### 1.1 Process Model

```
┌──────────────────────────────────────────────────┐
│                  SUPRA App                       │
│  ┌──────────────────────────────────────────┐   │
│  │            SwiftUI Application           │   │
│  │  ┌─────┐ ┌──────┐ ┌──────┐ ┌────────┐  │   │
│  │  │Views│ │Models│ │Services│ │Stores │  │   │
│  │  └─────┘ └──────┘ └──────┘ └────────┘  │   │
│  └──────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────┐   │
│  │         OpenCode Bridge                  │   │
│  │  ┌────────────┐ ┌──────────────────┐    │   │
│  │  │OpenCode    │ │  OpenCode      │    │   │
│  │  │Client     │ │  Bridge        │    │   │
│  │  └────────────┘ └──────────────────┘    │   │
│  └──────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────┐   │
│  │           Runtime Services               │   │
│  │  ┌──────┐ ┌─────────┐ ┌──────────┐     │   │
│  │  │Monitor│ │Gateway │ │DataSource│     │   │
│  │  └──────┘ └─────────┘ └──────────┘     │   │
│  └──────────────────────────────────────────┘   │
└──────────────────────────────────────────────────┘
```

### 1.2 Process Boundaries

| Process | Type | Technology | Communication |
|---------|------|------------|---------------|
| SUPRA App | Main | SwiftUI/AppKit | In-process |
| OpenCode Bridge | Service | Process communication | IPC |
| Runtime Monitor | Service | Swift Concurrency | async/await |
| Knowledge Engine | Service | Swift | async/await |
| Memory Store | Service | Swift | async/await |

### 1.3 Threading Model

| Thread Type | Usage | Components |
|-------------|-------|------------|
| Main Thread | UI updates | All Views |
| Concurrent Queue | Async operations | Networking, file I/O |
| Background Queue | Heavy computation | Knowledge graph, compilation |
| Timer Sources | Periodic tasks | Monitoring, health checks |

---

## 2. STORAGE TOPOLOGY

### 2.1 Storage Layers

| Layer | Location | Format | Access Pattern |
|-------|----------|--------|----------------|
| Session Memory | _FOUNDATION_MEMORY/ | JSON | Read/Write |
| Mission Archive | _MISSIONS/ | Markdown | Append-only |
| Factory State | FACTORIES/*/outputs/ | Various | Write-once |
| Configuration | .opencode/ | JSON | Read-heavy |
| Source Code | SUPRA/ | Swift | Read/Write |

### 2.2 Data Flow

```
Source Code (Swift)
  │
  ├──► Compiler (Xcode/Swift PM) ──► Build Artifacts
  │
  ├──► AST Platform ──► Analysis ──► Reports
  │
  └──► Documentation Generator ──► *.md
```

---

## 3. NETWORK TOPOLOGY

| Endpoint | Protocol | Purpose | Security |
|----------|----------|---------|----------|
| localhost:11434 | HTTP | Ollama API | Local only |
| OpenCode IPC | Unix socket | Agent communication | File permissions |

---

## 4. DEPLOYMENT TOPOLOGY

### 4.1 Node Configuration

| Property | Value |
|----------|-------|
| Node ID | supra-node-macbook-pro-de-nicolaslocal |
| Platform | macOS (arm64) |
| Runtime | Swift 6.x |
| Builder | opencode 1.18.5 |
| LLM Backend | Ollama 0.32.3 |

### 4.2 Resource Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| RAM | 16 GB | 32 GB |
| Disk | 10 GB | 50 GB |
| CPU | 4 cores | 8+ cores |
| GPU | Any Metal-capable | Apple Silicon |
