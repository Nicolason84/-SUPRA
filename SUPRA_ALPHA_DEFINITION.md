# SUPRA Alpha Definition

## Statut

**PROPOSAL — contrat binaire de produit.** Alpha est atteint seulement si chaque critère MUST est validé par test et preuve.

## Définition binaire de Done

| ID | Critère | Done si | Échec si |
|---|---|---|---|
| DONE-01 | Application unique | Un seul produit SUPRA est lancé pour le parcours Alpha | Plusieurs applications sont nécessaires |
| DONE-02 | Navigation unique | Toutes les surfaces Alpha sont accessibles par une navigation cohérente | Navigation parallèle ou écran isolé |
| DONE-03 | Runtime unique | Les surfaces lisent le Runtime canonique existant | État concurrent, simulé ou dupliqué |
| DONE-04 | Memory unique | Une source Memory existante sert le parcours | Mémoire dupliquée ou contexte divergent |
| DONE-05 | Executive Surface | Les huit informations obligatoires sont visibles | Une information critique manque |
| DONE-06 | Pilotage Codex | Une interaction Codex réelle est lancée et suivie depuis SUPRA | Bridge placeholder, incomplet ou simulation |
| DONE-07 | Missions | La mission active et son agenda sont consultables | Mission inaccessible ou ambiguë |
| DONE-08 | Preuves | Les preuves réelles sont consultables et reliées au travail | Démonstration factice seulement |
| DONE-09 | Runtime visible | État et activité Runtime sont compréhensibles | État masqué ou incohérent |
| DONE-10 | Erreurs visibles | Une erreur injectée ou réelle est présentée actionnablement | Échec silencieux |
| DONE-11 | Décisions visibles | Les décisions importantes sont consultables | Décisions absentes du parcours |
| DONE-12 | Stabilité réelle | Seuil d’utilisation réelle satisfait | Crash, perte de contexte ou double exécution |
| DONE-13 | Workspace | Un workspace NOVA OS réel est ouvert et repris | Workspace factice, inaccessible ou non restauré |
| DONE-14 | Recherche | Une recherche réelle retourne un résultat ouvrable | Recherche absente, factice ou résultat inutilisable |
| DONE-15 | Historique | L’historique réel permet de reprendre le travail | Historique absent, divergent ou non restauré |
| DONE-16 | Logs | Les logs réels sont accessibles et corrélables à une exécution | Logs absents, factices ou non corrélables |
| DONE-17 | Health | La santé réelle distingue au minimum état sain et dégradé | Santé absente, statique ou incohérente |

Le verdict global est `DONE` uniquement si DONE-01 à DONE-17 sont tous `PASS`. Les notifications restent `SHOULD HAVE / BETA` et ne constituent pas un gate Alpha.

## Contrat de l’Executive Surface

La surface principale affiche, sans navigation exploratoire:

1. mission active;
2. blocage actuel;
3. action suivante;
4. état Runtime;
5. dernières preuves;
6. progression;
7. santé système;
8. décisions importantes.

Chaque information est une projection d’une source existante. Aucune logique métier nouvelle ne réside dans la vue.

## Parcours quotidien de référence

1. L’utilisateur lance SUPRA.
2. SUPRA restaure la mission et le workspace réels.
3. L’Executive Surface indique l’action suivante.
4. L’utilisateur ouvre la mission puis pilote Codex.
5. Il suit Runtime, logs, santé et progression.
6. Il consulte une preuve et une décision.
7. Il ferme puis relance SUPRA.
8. Il reprend sans contexte perdu ni exécution dupliquée.

## Exigences non fonctionnelles Alpha

- Stabilité: zéro crash pendant la fenêtre de certification.
- Continuité: zéro perte de contexte après relance.
- Idempotence: zéro double exécution observée.
- Authenticité: workspace, mission, Codex, Runtime et preuves réels.
- Observabilité: erreurs, état et santé visibles.
- Réversibilité: chaque mission possède un rollback vérifié.
- Simplicité: aucune nouvelle architecture, engine, store, Runtime ou shell.
- Performance: aucune dégradation bloquant une session quotidienne; les seuils chiffrés sont résolus au précheck à partir de la baseline.

## Seuil d’usage réel

La certification exige trois sessions d’au moins deux heures ou une journée d’au moins six heures, sur un workspace NOVA OS réel. Une démo courte, des fixtures ou des captures statiques ne suffisent pas.

## Reports volontaires

Sont reportés hors Alpha: perfection visuelle, automatisations autonomes, univers graphiques avancés, fonctions business et migration exhaustive des fonctions historiques.
