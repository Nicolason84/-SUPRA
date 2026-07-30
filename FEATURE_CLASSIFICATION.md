# Feature Classification

## Règles

- `MUST HAVE / ALPHA`: nécessaire au parcours quotidien ou à sa certification.
- `SHOULD HAVE / BETA`: améliore fortement l’usage après Alpha.
- `COULD HAVE / V2`: utile mais non bloquant.
- `NOT NOW / FUTURE`: ne rapproche pas du produit Alpha.

La colonne « composant existant » est une cible de réemploi à confirmer au précheck; aucun nom de type non vérifié n’est inventé.

| Capacité | Classe | Horizon | Justification | Composant existant à réemployer | Preuve / gate |
|---|---|---|---|---|---|
| Mission active | MUST HAVE | ALPHA | Centre du travail courant | Surface Mission existante | Mission réelle visible et restaurée |
| Agenda d’exécution | MUST HAVE | ALPHA | Rend l’action suivante explicite | Données Mission existantes | Étapes et prochaine action visibles |
| État Runtime | MUST HAVE | ALPHA | Rend le système compréhensible | Runtime Dashboard/canonique existant | État réel cohérent sur deux surfaces |
| Pilotage Codex | MUST HAVE | ALPHA | Remplace le détour terminal/prompt | Bridge Codex existant | Interaction réelle; placeholder = NO-GO |
| Historique | MUST HAVE | ALPHA | Permet la reprise | Historique existant | Reprise après relance |
| Evidence | MUST HAVE | ALPHA | Rend le travail vérifiable | Surface Evidence existante | Preuve réelle consultable |
| Logs | MUST HAVE | ALPHA | Rend les erreurs diagnostiquables | Logs Runtime existants | Erreur visible et actionnable |
| Memory | MUST HAVE | ALPHA | Préserve le contexte | Memory existante | Zéro perte de contexte |
| Recherche | MUST HAVE | ALPHA | Rend le workspace praticable | Recherche Workspace existante | Résultat réel ouvrable |
| Navigation | MUST HAVE | ALPHA | Unifie l’application | Shell/navigation la plus mature | Un seul chemin de navigation |
| Health | MUST HAVE | ALPHA | Signale les blocages | Santé Runtime existante | État sain/dégradé vérifiable |
| Notifications | SHOULD HAVE | BETA | Réduit la surveillance manuelle | Notifications existantes | Scénario Beta à approuver |
| Workspace | MUST HAVE | ALPHA | Donne accès au projet NOVA OS | Workspace V5/existant | Workspace réel ouvert |
| Decisions | MUST HAVE | ALPHA | Maintient la traçabilité exécutive | Surface Decisions existante | Décision réelle consultable |
| Providers | SHOULD HAVE | BETA | Utile à l’exploitation avancée | Surface Providers existante | Provider réel et état vérifié |
| Reports | COULD HAVE | V2 | Support, pas finalité Alpha | Lecteur de rapports existant | Besoin réel démontré |
| Developer | SHOULD HAVE | BETA | Outils avancés non essentiels au premier parcours | Surface Developer existante | Parcours Beta validé |
| Discovery | COULD HAVE | V2 | Exploration non bloquante | Surface Discovery existante | Cas d’usage récurrent démontré |
| Progression | MUST HAVE | ALPHA | Répond à « où en suis-je ? » | Données Mission existantes | Progression cohérente |
| Blocage courant | MUST HAVE | ALPHA | Oriente l’action immédiate | Mission/Health existants | Blocage réel affiché |
| Action suivante | MUST HAVE | ALPHA | Répond à la question centrale | Mission/agenda existants | Action non ambiguë |
| Erreurs visibles | MUST HAVE | ALPHA | Évite les échecs silencieux | Runtime/logs existants | Erreur provoquée observée |
| Recovery/relaunch | MUST HAVE | ALPHA | Rend l’outil quotidien | Recovery existante | Relance sans perte/doublon |
| Executive Surface | MUST HAVE | ALPHA | Point d’entrée unique | Executive Cockpit existant | Huit blocs obligatoires |
| Graphes avancés | NOT NOW | FUTURE | Aucun besoin Alpha | Composants éventuels gelés | Nouvelle décision produit requise |
| Digital twins | NOT NOW | FUTURE | Spéculatif | Aucun nouveau composant | Nouvelle décision produit requise |
| Universe | NOT NOW | FUTURE | Hors parcours quotidien | Aucun nouveau composant | Nouvelle décision produit requise |
| Spatial | NOT NOW | FUTURE | Hors Alpha | Aucun nouveau composant | Nouvelle décision produit requise |
| Business | NOT NOW | FUTURE | Ne débloque pas NOVA OS | Aucun nouveau composant | Stratégie produit séparée |
| Monétisation | NOT NOW | FUTURE | Prématurée | Aucun nouveau composant | Stratégie produit séparée |
| Autonomie | NOT NOW | FUTURE | Risque élevé avant stabilité | Aucun nouveau composant | Gouvernance future |
| Nouveaux engines | NOT NOW | FUTURE | Interdit par la mission | Aucun | Toute création = STOP |
| Nouveau store | NOT NOW | FUTURE | Duplique l’ownership | Aucun | Toute création = STOP |
| Nouveau Runtime | NOT NOW | FUTURE | Contredit l’unicité | Aucun | Toute création = STOP |
| Nouveau shell/dashboard | NOT NOW | FUTURE | Crée une quatrième interface | Aucun | Toute création = STOP |

