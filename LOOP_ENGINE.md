# Loop Engine

> **DRAFT — PLAN STRUCTURÉ MAIS PARTIEL — NOT READY FOR IMPLEMENTATION**
>
> [FACT] `EXECUTIVE_EVENT_MODEL.md`, `RUNTIME_LAWS.md` et `UI_PHILOSOPHY.md` sont absents des sources autorisées. **G0 est rouge.**
> [EVIDENCE] Base exclusive: `ULTIMATE_CONSOLIDATION_REPORT.md`, `SUPRA_CANON.md`, `EXECUTIVE_RUNTIME.md`, `EXECUTIVE_OBJECT_MODEL.md`, `AGENTS.md`, `DEPENDENCY_MAP.md`.
> [PROPOSAL] Toute sortie produit décrite ici est future. Aucun contrat manquant n’est inventé.

```text
ANALYSE → DÉCISION → PRECHECK → IMPLÉMENTATION → VALIDATION → AUDIT
     ↑                                               │ FAIL (max 2)
     └──────────── CORRECTION + nouveau patch ───────┘
AUDIT PASS → SNAPSHOT → CERTIFY → FREEZE → NEXT
FAIL #3 → rollback before → ESCALADE HUMAINE → SOURCE-BLOCKED
```

| État stable | Condition mesurable | Action permise |
|---|---|---|
| SOURCE-BLOCKED | doctrine/dépendance absente consignée dans certificate.md | documentation seulement |
| PRECHECKED | status attribuable, hashes et test before exit 0 | Builder peut patcher |
| FROZEN | manifest.sha256 + certificate PASS + human gate | NEXT seulement |
| ESCALATED | hashes restaurés égaux au before, test exit 0 | décision humaine |

[PROPOSAL] Deux corrections maximum. Une correction modifie uniquement l’allowlist existante, archive l’ancien patch, recalcule hashes et rejoue exactement le test. Tout changement d’allowlist retourne à PLAN. Les communications événementielles restent SOURCE-BLOCKED tant que le modèle d’événements manque.

