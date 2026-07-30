# PROJECT PHOENIX — Executive Runtime Reconstruction Charter

**Status**: ACTIVE  
**Branch**: `executive-runtime-v2`  
**Started**: 2026-07-30  
**Authority**: SUPRA Executive — Reconstruction Order  

---

## MISSION

Reconstruire le noyau exécutif de SUPRA pour qu'il devienne un **Runtime vivant**.

Ce n'est pas une réécriture. Ce n'est pas un nouveau projet.  
C'est une reconstruction architecturale du système nerveux.

---

## PRINCIPES

1. **Toute interface future doit être une conséquence naturelle du Runtime.**
2. **Aucun accès direct aux services depuis SwiftUI.**
3. **Executive Context Snapshot = seule source de vérité pour les vues.**
4. **Event Bus = seul canal de communication inter-moteurs.**
5. **ŒIL = première manifestation visible du Runtime vivant.**
6. **PRÉSENCE = orchestration perceptive, pas technique.**

---

## ORDRE DE RECONSTRUCTION

| Ω | Composant | Fichier | Dépendances |
|---|-----------|---------|-------------|
| Ω1 | Executive Runtime Core | `ExecutiveRuntimeCore.swift` | — |
| Ω2 | Vision Engine | `VisionEngine.swift` | Ω1 |
| Ω3 | Presence Engine | `PresenceEngine.swift` | Ω1, Ω2 |
| Ω4 | Context Engine | `ContextEngine.swift` | Ω1 |
| Ω5 | Executive Context Snapshot | `ExecutiveContextSnapshot.swift` | Ω4 |
| Ω6 | Executive Snapshot Bus | `ExecutiveSnapshotBus.swift` | Ω5 |
| Ω7 | Executive Event Bus | `ExecutiveEventBus.swift` | Ω1 |
| Ω8 | Digital Twin Runtime | `DigitalTwinRuntime.swift` | Ω1, Ω5 |
| Ω9 | Identity Runtime | `IdentityRuntime.swift` | Ω1 |
| Ω10 | ŒIL (Perception Layer) | `OeilPerceptionLayer.swift` | Ω2, Ω3, Ω5 |

---

## ARCHITECTURE

```
┌─────────────────────────────────────────────────────┐
│                   Executive Runtime Core (Ω1)        │
│  Boot · Lifecycle · Health · Coordination           │
└──────┬──────────┬──────────┬─────────────┬──────────┘
       │          │          │             │
       ▼          ▼          ▼             ▼
┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│  Vision  │ │ Presence │ │ Context  │ │ Identity │
│  Engine  │ │  Engine  │ │  Engine  │ │ Runtime  │
│   (Ω2)   │ │   (Ω3)   │ │   (Ω4)   │ │   (Ω9)   │
└────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘
     │            │            │             │
     └────────────┴────────────┴─────────────┘
                      │
                      ▼
            ┌──────────────────┐
            │  Context Snapshot │
            │       (Ω5)       │
            └────────┬─────────┘
                     │
            ┌────────┴─────────┐
            │  Snapshot Bus (Ω6) │
            │  Event Bus (Ω7)    │
            └────────┬─────────┘
                     │
                     ▼
            ┌──────────────────┐
            │  Digital Twin (Ω8) │
            └──────────────────┘
                     │
                     ▼
            ┌──────────────────┐
            │   ŒIL (Ω10)      │
            │  Perception Layer │
            └──────────────────┘
```

---

## RÈGLES D'INTERFACE

- **Read Only**: Tous les agents sauf SUPRA-Builder
- **Single Writer**: SUPRA-Builder uniquement
- **Evidence**: Toute modification doit être précédée par une preuve
- **Snapshot Only**: Les vues ne lisent que le ExecutiveContextSnapshot
- **Events Only**: Les moteurs communiquent via ExecutiveEventBus

---

## CRITÈRES DE VALIDATION

- [x] Branche `executive-runtime-v2` créée
- [ ] Ω1 — Executive Runtime Core compile et s'initialise
- [ ] Ω2 — Vision Engine observe le projet
- [ ] Ω3 — Presence Engine publie la présence
- [ ] Ω4 — Context Engine produit le contexte
- [ ] Ω5 — Executive Context Snapshot est structuré et publié
- [ ] Ω6 — Snapshot Bus distribue les snapshots
- [ ] Ω7 — Event Bus achemine les événements
- [ ] Ω8 — Digital Twin Runtime reflète l'état système
- [ ] Ω9 — Identity Runtime maintient l'identité SUPRA
- [ ] Ω10 — ŒIL est vivant

---

## FREEZE

Tous les modules existants sont gelés jusqu'à la reconnexion :
- Cockpit
- Mission Center
- Decision Center
- Knowledge Center
- Runtime UI
- Workflows
- Discovery
- Settings

Aucune nouvelle fonctionnalité. Aucun nouvel écran. Aucun nouveau module.
