# SUPRA_OPENCODE_PROVIDER_VALIDATION_V1 — PROTOCOLE

## État actuel
- Patch appliqué à SUPRA/opencode.json
- Clés ajoutées: provider, model, small_model
- Valeurs identiques à la config globale

## Instructions de validation

### 1. Quitter cette session OpenCode (Ctrl+C ou /quit)

### 2. Relancer OpenCode dans le répertoire SUPRA
```bash
cd ~/Desktop/NOVA_OS/SUPRA
opencode
```

### 3. Envoyer les prompts de test dans cet ordre
1. `hello` — test basique
2. `Quel est le capital de la France ?` — prompt court
3. `Explique en détail comment fonctionne le protocole TCP/IP, couche par couche` — prompt moyen
4. `Rédige un guide complet sur les design patterns en Swift avec des exemples de code pour chaque pattern` — prompt long
5. `Crée une fonction Swift qui valide une adresse email` — mission simple
6. `Crée un système complet de gestion de tâches avec persistence, tri et filtrage` — mission complexe

### 4. Vérifier les résultats
Après chaque prompt, vérifier:
- Le provider utilisé (devrait être OLLAMA_LOCAL)
- Le modèle utilisé (devrait être qwen3-coder)
- Le streaming (devrait fonctionner sans erreur)

### 5. Forcer la compaction
Continuez à envoyer des prompts jusqu'à ce que la compaction se déclenche (conversation suffisamment longue).

### 6. Vérifier les logs
```bash
tail -100 ~/.local/share/opencode/log/opencode.log | grep -E "providerID|modelID|Streaming|error|compaction"
```

## Résultat attendu
Si le patch est efficace:
- Tous les prompts utilisent OLLAMA_LOCAL/qwen3-coder
- Pas de basculement vers le provider opencode
- Pas d'erreurs de streaming
- La compaction fonctionne normalement

## Si le patch ne résout pas le problème
Le blocage persiste malgré le patch → hypothèse C ou D
