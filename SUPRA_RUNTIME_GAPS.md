# SUPRA RUNTIME GAPS — V1

## Mission : SUPRA_ALIVE_BOOTSTRAP_004

## Diagnostic des écarts entre l'état actuel et le système vivant

---

### Gap 1 : Aucun appel LLM — CRITIQUE

**Problème :** `SUPRAMissionExecutor.execute()` est une machine d'état qui ne fait rien. Elle vérifie `canAutoExecute()` mais n'exécute aucune action réelle. Il n'existe aucun code capable d'envoyer un prompt à un modèle de langage.

**Impact :** Le système est une coquille documentaire. Aucune mission ne peut produire de résultat concret.

**Solution :**
- Créer `SUPRAProviderProtocol` (définit l'interface LLM)
- Créer `SUPRAProviderBroker` (router vers le bon provider)
- Créer `SUPRAOllamaProvider` (premier provider concret — local, souverain)
- Modifier `SUPRAMissionExecutor.execute()` pour appeler le broker

---

### Gap 2 : Aucune abstraction provider — CRITIQUE

**Problème :** Le code Swift actuel ne contient aucune abstraction pour les appels LLM. Il y a un `KnowledgeProvider` protocol, mais c'est pour des sources de données, pas des modèles d'IA. Il y a des `ProviderMetrics` dans RuntimeModels, mais ce sont des métriques de runtime, pas d'IA.

**Impact :** Impossible de brancher un LLM sans réécrire l'architecture.

**Solution :**
- Créer le protocole `SUPRAProvider` avec `execute(request:) → ProviderResponse`
- Tous les composants système dépendent de ce protocole, pas d'une implémentation

---

### Gap 3 : MissionExecutor non connecté au provider — HAUT

**Problème :** `SUPRAMissionExecutor` et `SUPRAProviderBroker` sont indépendants. Aucune connexion n'existe.

**Impact :** Même avec un provider, l'executor ne peut pas l'appeler.

**Solution :**
- Connecter `SUPRAMissionExecutor` → `SUPRAProviderBroker` dans la boucle d'exécution

---

### Gap 4 : Pas de routage mission → LLM — HAUT

**Problème :** Aucun composant ne traduit une mission en prompt LLM. `SUPRAMissionProposalEngine` génère des propositions, mais ne construit pas de requête exécutable.

**Impact :** Le système ne sait pas quoi envoyer au LLM.

**Solution :**
- `SUPRAMissionBroker.route()` construit `ExecutionRequest` (prompt + system prompt + paramètres)
- Le prompt est enrichi par `NOVAKnowledgeKernel` avec le contexte

---

### Gap 5 : Pas de cycle décision → mémoire → UI — MOYEN

**Problème :** Le pipeline `Response → Decision → Memory → UI` est théoriquement possible avec les composants existants, mais aucune connexion n'est implémentée.

**Impact :** Le système répond à une mission mais ne se souvient pas de ce qu'il a fait.

**Solution :**
- Connecter `SUPRADecisionStore.record()` après chaque exécution
- Connecter `MultiMemoryStore.rebuild()` après chaque décision
- Les @Published Combine propagent automatiquement à l'UI

---

### Gap 6 : Pas de gestion d'erreur LLM — MOYEN

**Problème :** Aucun mécanisme de retry, timeout, ou fallback n'existe pour les appels LLM.

**Impact :** Si le provider local (Ollama) n'est pas disponible, la mission échoue sans fallback.

**Solution :**
- `SUPRAProviderBroker` implémente retry (3 tentatives)
- Fallback automatique vers un autre provider si le principal est indisponible
- Timeout configurable par `ExecutionRequest`

---

### Gap 7 : Pas de mode dégradé — MOYEN

**Problème :** Si aucun LLM n'est disponible, le système doit pouvoir fonctionner en mode dégradé (réponses pré-enregistrées, chaînes déterministes).

**Impact :** Le système est inutilisable sans LLM.

**Solution :**
- Provider "fallback" intégré qui utilise des templates de réponse
- Détection de disponibilité au démarrage

---

### Gap 8 : Pas de persistance des réponses — BAS

**Problème :** Les réponses LLM ne sont pas persistées en dehors des stores mémoire.

**Impact :** Impossible de rejouer ou auditer une mission.

**Solution :**
- `ExecutionRecord` étendu avec `response: ProviderResponse?`
- Persistance optionnelle dans `DecisionStore`

---

### Gap 9 : Pas de hook utilisateur avant exécution — BAS

**Problème :** Aucun mécanisme pour qu'un utilisateur valide ou modifie une mission avant exécution LLM.

**Impact :** Pas de contrôle humain sur le pipeline.

**Solution :**
- `SUPRAMissionBroker` expose un événement `pendingUserApproval`
- L'UI affiche le `ExecutionRequest` proposé et attend validation

---

## Synthèse des gaps

| Gap | Priorité | Bloque la boucle ? | Effort | Dépend de |
|-----|----------|-------------------|--------|-----------|
| 1. Aucun appel LLM | CRITIQUE | OUI | 1j | Rien |
| 2. Abstraction provider | CRITIQUE | OUI | 0.5j | Rien |
| 3. Executor non connecté | HAUTE | OUI | 0.5j | Gap 1+2 |
| 4. Routage mission | HAUTE | OUI | 0.5j | Gap 2 |
| 5. Cycle mémoire | MOYENNE | NON (phase 2) | 0.5j | Gaps 1-4 |
| 6. Gestion erreur | MOYENNE | NON | 0.5j | Gap 2 |
| 7. Mode dégradé | MOYENNE | NON | 0.5j | Gap 2 |
| 8. Persistance | BASSE | NON | 0.25j | Gaps 1-4 |
| 9. Hook utilisateur | BASSE | NON | 0.25j | Gap 4 |

## Condition de déblocage

**Le système peut exécuter sa première mission LLM dès que les gaps 1, 2, 3, 4 sont résolus.**
Soit : protocole provider + broker + Ollama provider + mission broker + executor modifié.
