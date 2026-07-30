MISSION_ID
LOT5_SUPRA_CHAT_GATEWAY_V1

ROLE
Tu es l’unique Codex intégrateur du produit macOS SwiftUI SUPRA.

WORKSPACE
/Users/nicolasalonso/Desktop/NOVA_OS/SUPRA

ÉTAT AUTORITAIRE CONFIRMÉ
- SUPRA compile.
- SUPRA se lance.
- Runtime Operational.
- Required Artifacts 6/6.
- Optional Artifacts 1/1.
- INDEX Available.
- _EXTRACTION_PLAN a été retiré de la racine runtime et conservé sous
  _NON_RUNTIME_ARCHITECTURE.
- Ne jamais remettre _EXTRACTION_PLAN dans SUPRA/SUPRA.
- Ne pas recréer un deuxième moteur, Mission Center ou registre générique.
- Réutiliser les modèles, stores, vues et routes existants.

OBJECTIF PRODUIT
Ajouter à SUPRA un workspace natif nommé :

SUPRA Chat

Ce workspace permet à Nicolas d’envoyer une demande en langage naturel à
SUPRA afin de :

1. interroger l’environnement canonique ;
2. comprendre les artefacts existants ;
3. préparer une mission structurée ;
4. transmettre cette mission au Mission Center après validation humaine.

PORTÉE V1 STRICTE
Modes autorisés :

- ASK
  Lecture, explication et recherche contextuelle.
  Aucune mutation.

- PLAN
  Génération d’un brouillon de mission JSON.
  Aucune exécution.

Mode interdit en V1 :

- EXECUTE
- Terminal libre
- lancement de scripts arbitraires
- suppression
- déplacement de sources
- mutation d’artefacts canoniques
- scan global de l’iMac

OLLAMA
Utiliser l’API locale :

http://127.0.0.1:11434/api

Endpoints utiles :

- GET /api/tags
- POST /api/chat

Le client doit :

- fonctionner avec URLSession ;
- ne pas bloquer le thread principal ;
- fournir un timeout raisonnable ;
- afficher clairement OFFLINE si Ollama est inaccessible ;
- récupérer la liste réelle des modèles installés ;
- permettre de sélectionner un modèle ;
- ne jamais coder en dur un modèle supposé présent ;
- utiliser stream=false dans V1 afin de réduire la complexité ;
- gérer proprement erreurs HTTP, JSON invalide et réponse vide.

ARCHITECTURE À PRODUIRE
Adapter les noms aux conventions réellement observées dans le projet, mais
viser les responsabilités suivantes :

1. SupraChatModels.swift
   - SupraChatMode : ask, plan
   - SupraChatRole : user, assistant, system
   - SupraChatMessage
   - SupraChatSession
   - SupraChatMissionDraft
   - SupraChatEvidenceReference
   - structures Codable pour Ollama

2. SupraOllamaClient.swift
   - actor ou composant Sendable approprié
   - listModels()
   - chat(messages:model:context:)
   - URLSession async/await
   - aucune commande shell

3. SupraChatContextResolver.swift
   - réutiliser les chemins et lecteurs déjà présents
   - lire uniquement les artefacts disponibles :
     INDEX
     MANIFEST
     ESTATE
     lots
     Mission Center
   - contexte borné
   - ne pas injecter des fichiers entiers massifs
   - inclure chemin, type, statut et extraits utiles
   - aucune exploration globale du disque

4. SupraChatStore.swift
   - @MainActor
   - état de conversation
   - modèles disponibles
   - modèle sélectionné
   - statut Ollama
   - envoi ASK
   - génération PLAN
   - erreurs lisibles
   - persistance locale contrôlée si une convention existante le permet

5. SupraChatView.swift
   - interface native cohérente avec SUPRA
   - historique lisible
   - sélecteur ASK / PLAN
   - sélecteur de modèle
   - état CONNECTED / OFFLINE
   - champ de saisie
   - bouton Envoyer
   - indicateur de travail
   - panneau Preuves utilisées
   - panneau Mission Draft en mode PLAN
   - boutons :
       Copier
       Enregistrer le brouillon
       Envoyer au Mission Center
   - le bouton Mission Center doit créer/importer une mission planifiée,
     jamais l’exécuter

6. Intégration navigation
   - inspecter d’abord la navigation actuelle réelle
   - ajouter exactement une route SUPRA Chat
   - ne pas réécrire ContentView
   - patch minimal et borné
   - préserver Dashboard, Decision Inbox, Mission Center,
     Runtime Monitor, Evidence Explorer et Capability Browser

CONTRAT MISSION DRAFT
Le JSON généré doit contenir au minimum :

{
  "mission_id": "string",
  "title": "string",
  "objective": "string",
  "mode": "READ_ONLY|PLAN_ONLY",
  "priority": "LOW|MEDIUM|HIGH",
  "status": "PLANNED",
  "requested_by": "FOUNDER",
  "created_at": "ISO-8601",
  "context": [],
  "evidence": [],
  "actions": [],
  "expected_outputs": [],
  "dependencies": [],
  "risks": [],
  "human_gate_required": true,
  "execution_authorized": false
}

PROMPT SYSTÈME LOCAL
Le système transmis à Ollama doit imposer :

- ne rien inventer ;
- distinguer faits, inférences et informations absentes ;
- citer les artefacts locaux utilisés ;
- ne jamais prétendre avoir exécuté une action ;
- produire du JSON strict en mode PLAN ;
- execution_authorized doit toujours rester false ;
- human_gate_required doit toujours rester true.

MISSION CENTER
Avant toute intégration :

- lire Mission.swift ;
- lire MissionStore.swift ;
- lire MissionCenterView.swift ;
- identifier le format réel ;
- adapter SupraChatMissionDraft au modèle existant ;
- éviter tout doublon dans le registre ;
- si l’import direct est trop risqué, sauvegarder le brouillon dans une Inbox
  dédiée et fournir un bouton d’ouverture vers Mission Center.

SÉCURITÉ
Interdictions absolues :

- Process()
- NSTask
- /bin/zsh
- /bin/bash
- AppleScript
- osascript
- commandes Terminal
- tool calling exécutable
- écriture hors du workspace SUPRA
- accès réseau autre que 127.0.0.1:11434
- modification de freezes validés
- modification de _NON_RUNTIME_ARCHITECTURE
- modification du binding INDEX
- réintégration de _EXTRACTION_PLAN

SAUVEGARDE
Avant toute mutation :

- créer une sauvegarde horodatée sous :
  _SUPRA_BACKUPS/LOT5_SUPRA_CHAT_GATEWAY_V1_<timestamp>
- copier chaque fichier existant qui sera modifié
- écrire BACKUP_MANIFEST.json

MÉTHODE
1. inspecter le projet réel ;
2. identifier précisément la navigation et le Mission Store ;
3. écrire un plan court dans :
   _MISSIONS/LOT5_SUPRA_CHAT_GATEWAY_V1/IMPLEMENTATION_PLAN.md
4. appliquer uniquement les modifications nécessaires ;
5. vérifier qu’aucun fichier Swift n’est créé dans un dossier exclu ;
6. vérifier les interdictions de sécurité par grep ;
7. compiler ;
8. corriger jusqu’à build PASS ;
9. lancer un smoke test non destructif ;
10. produire le rapport final.

BUILD OBLIGATOIRE
Utiliser :

xcodebuild \
  -project SUPRA.xcodeproj \
  -scheme SUPRA \
  -configuration Debug \
  -destination 'platform=macOS' \
  clean build \
  CODE_SIGNING_ALLOWED=NO

ROLLBACK
Si le build final échoue :

- restaurer tous les fichiers sauvegardés ;
- supprimer seulement les nouveaux fichiers créés par cette mission ;
- recompiler l’état antérieur ;
- inscrire ROLLBACK_COMPLETED dans le rapport ;
- ne jamais laisser le projet cassé.

TESTS MINIMAUX
Valider :

- build PASS ;
- route Supra Chat présente ;
- aucune déclaration Swift dupliquée ;
- aucune référence runtime à _EXTRACTION_PLAN ;
- aucun Process/NSTask/shell/osascript dans LOT5 ;
- Ollama OFFLINE géré sans crash ;
- JSON Mission Draft validable ;
- human_gate_required=true ;
- execution_authorized=false ;
- Mission Center existant préservé ;
- Dashboard existant préservé.

RAPPORT OBLIGATOIRE
Créer exactement :

/Users/nicolasalonso/Desktop/NOVA_OS/SUPRA/_MISSIONS/LOT5_SUPRA_CHAT_GATEWAY_V1/LOT5_SUPRA_CHAT_GATEWAY_V1_REPORT.json

Schéma minimal :

{
  "mission_id": "LOT5_SUPRA_CHAT_GATEWAY_V1",
  "status": "PASS|FAILED|ROLLED_BACK",
  "build": "PASS|FAILED",
  "rollback": "NOT_REQUIRED|COMPLETED|FAILED",
  "ollama_endpoint": "http://127.0.0.1:11434/api/chat",
  "modes": ["ASK", "PLAN"],
  "execute_enabled": false,
  "human_gate_required": true,
  "files_created": [],
  "files_modified": [],
  "backup_directory": "",
  "tests": {},
  "warnings": [],
  "next_action": ""
}

SORTIE FINALE CODEX
Répondre uniquement avec :

- verdict ;
- build ;
- fichiers créés ;
- fichiers modifiés ;
- sauvegarde ;
- tests ;
- prochaine action.

Commence maintenant par inspecter les sources réelles.
Ne demande aucune clarification.
