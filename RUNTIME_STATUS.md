# ALPHA-01 — Runtime Status

## Verdict Runtime minimal

**LAUNCH PASS — OPERATIONAL DATA DEGRADED**

L’application compilée démarre, rend une fenêtre et reste active sans crash immédiat. Le contenu observé n’atteste toutefois pas une publication Runtime complète.

## Chaîne d’entrée observée

La chaîne d’entrée du produit passe par le target `SUPRA`, l’application SwiftUI déclarée dans `SUPRAApp.swift`, puis la composition/racine de contenu existante jusqu’à l’Executive Surface. Aucun entry point alternatif n’a été créé ou activé par ALPHA-01.

La présence d’`ExecutiveBootManager` dans le dépôt ne suffit pas à prouver son déclenchement. L’état affiché suggère que la publication attendue n’a pas atteint la surface pendant la fenêtre d’observation ; cette formulation est une observation et non une conclusion causale.

## Preuves de lancement

| Preuve | Valeur |
|---|---|
| App lancée | `/private/tmp/SUPRA_ALPHA01_DERIVED/Build/Products/Debug/SUPRA.app` |
| Processus | PID `16000` |
| Persistance | présent lors du contrôle après lancement |
| Fenêtre | titre `SUPRA` |
| Crash immédiat | aucun observé |
| Signature | ad hoc, identifiant confirmé par `codesign` |
| Capture | `/private/tmp/SUPRA_ALPHA01_RUNTIME_LAUNCH.png` |
| SHA-256 capture | `7a27926899fbf913b18944e5d21b569412dc17c2a4e0412f86eb2f490090b281` |

Le fichier de profilage vide `default.profraw` créé pendant ce lancement a été retiré avant certification ; aucun source ni état Runtime n’a été modifié.

## État visible

Les libellés suivants sont visibles :

- `WAITING FOR DATA`
- `Standby`
- `Health SYNC`
- `awaiting publication`
- badge `OPERATIONAL`

Le badge `OPERATIONAL` est contradictoire avec l’absence de données publiée. Il ne doit pas être utilisé seul comme preuve de santé Runtime. La seule certification accordée ici est le lancement minimal sans crash immédiat.

## Limites

- Aucun flux métier end-to-end n’a été certifié.
- Aucune publication canonique de `RuntimeSnapshot` n’a été démontrée.
- Aucun fichier de log Runtime persistant n’a été établi.
- La Memory, les missions, les décisions, les preuves et le Codex Bridge ne sont pas certifiés par ALPHA-01.
- L’absence de crash est limitée à la fenêtre d’observation, pas à une campagne de longévité.
- La suite complète de tests n’a pas terminé.

## Statut des sous-systèmes

| Sous-système | Statut observé | Certification |
|---|---|---|
| Processus macOS | Actif | PASS minimal |
| Fenêtre SwiftUI | Rendue | PASS minimal |
| Runtime data | En attente | NON CERTIFIÉ |
| Health | `SYNC` affiché | NON CERTIFIÉ |
| Mission active | Non démontrée | NON CERTIFIÉ |
| Memory | Non démontrée | NON CERTIFIÉ |
| Evidence/logs | Non démontrés | NON CERTIFIÉ |
| Providers | Build/link réussi ; runtime non démontré | PARTIEL |

## Conclusion

Le Runtime est suffisamment lançable pour commencer ALPHA-02. Son état de données et sa cohérence visuelle devront être traités par les missions prévues, sans réécriture du Runtime.
