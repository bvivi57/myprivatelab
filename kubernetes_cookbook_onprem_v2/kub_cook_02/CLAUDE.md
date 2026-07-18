# xkub.coolcorp.priv.iac — Consignes Claude Code (Terraform)

## Objectif du dossier

Déployer les **11 VMs** du cluster depuis le template Packer, via le provider
**`vatesfr/xenorchestra`** (API Xen Orchestra), et **générer l'inventaire Ansible**.
Le nœud baremetal prdk8smin520 est HORS périmètre Terraform (ajout manuel à
l'inventaire). Lire d'abord `../CLAUDE.md` et `../docs/ARCHITECTURE.md`.

## Inventaire à créer

| Groupe | VMs | Réseau XO |
|---|---|---|
| k8s_controlplane_lan | prdk8sgru501-503 | LAN |
| k8s_workers_lan | prdk8smin501-502 | LAN |
| k8s_workers_web | prdk8smin510-511 | DMZ |
| nlb_haproxy_lan | prdnlbhap501-502 | LAN |
| nlb_haproxy_web | prdnlbhap510-511 | DMZ |

Groupes **transverses** générés en plus (parents des groupes de rôle ci-dessus,
aucun hôte déclaré en direct) :

| Groupe | Membres |
|---|---|
| clu_k8s_xkub | toutes les machines de la plateforme (5 groupes de rôle + gpu) |
| os_lin_r10 | toutes les machines (Rocky Linux 10 partout, baremetal inclus) |
| sys_net_lan | groupes LAN : k8s_controlplane_lan, k8s_workers_lan, nlb_haproxy_lan, gpu |
| sys_net_web | groupes DMZ : k8s_workers_web, nlb_haproxy_web |

Groupes **applicatifs** (hôtes déclarés directement, dérivés du flag `traefik = true`
posé par nœud dans le tfvars — autorisé sur les workers uniquement, validation) :

| Groupe | VMs |
|---|---|
| k8s_traefik_lan | prdk8smin501-502 (instance Traefik LAN) |
| k8s_traefik_web | prdk8smin510-511 (instance Traefik DMZ) |

## Contraintes techniques

- Provider épinglé dans `versions.tf`. Vérifier la version courante du provider
  xenorchestra et la syntaxe des ressources (`xenorchestra_vm`, datasources template/
  network/SR) dans la doc officielle avant d'écrire — l'API du provider évolue.
- Authentification XO : `XOA_URL` + `XOA_TOKEN` en variables d'environnement
  uniquement. Rien dans le code, rien dans git.
- **Structure** :
  ```
  versions.tf  variables.tf  main.tf  outputs.tf
  modules/k8s-node/      (VM générique : clone template + cloud-init)
  templates/cloud-init/  (user-data et network-config en templatefile)
  templates/inventory.tftpl
  ```
  Un seul module VM paramétrable (rôle, zone, taille) plutôt que deux modules quasi
  identiques — les HAProxy n'ont pas de besoin différent au niveau infra.
- **cloud-init** (NoCloud via attributs `cloud_config`/`cloud_network_config` du
  provider) : hostname FQDN, IP statique, passerelle, DNS coolcorp.priv,
  search domain. Pas de duplication de la clé SSH (déjà dans le template) sauf
  renforcement explicite demandé.
- Tailles VMs (vCPU/RAM/disque) : variables par groupe, valeurs dans
  `terraform.tfvars` (committé si non sensible). Demander les valeurs à Vincent si
  absentes de `../docs/ARCHITECTURE.md`.
- **Anti-affinité** : si le pool XCP-ng a plusieurs hôtes, répartir les CP et chaque
  paire HAProxy sur des hôtes distincts (attribut affinity/host du provider si
  disponible, sinon documenter la limite).

## Génération de l'inventaire Ansible

- `outputs.tf` + ressource `local_file` → écrit
  `../xkub.coolcorp.priv.ansible/inventory/hosts.yml` via `yamlencode(local.inventory)`
  (structure dans `locals.tf` ; pas de template texte, YAML garanti valide).
- Groupes générés : les 5 groupes de rôle + `gpu` (vide), enfants du parent
  `clu_k8s_xkub` ; groupes transverses `os_lin_r10`, `sys_net_lan`, `sys_net_web`
  construits par références `children` vers les groupes de rôle ; groupes applicatifs
  `k8s_traefik_lan` / `k8s_traefik_web` dérivés du flag `traefik` (cf. tables §Inventaire).
- **Tags XO** : chaque VM reçoit ses groupes d'inventaire en tags XAPI
  (`local.node_tags` → attribut `tags` du module). Inventaire et tags sont deux
  projections de la même source `var.nodes` — ne jamais les faire diverger.
- **Nommage des groupes : underscores uniquement** (best practice Ansible — un nom de
  groupe doit être un identifiant Python valide ; des tirets déclenchent le warning
  « Invalid characters were found in group names »). Les tirets restent réservés aux
  hostnames/FQDN, qui ne sont pas concernés.
- Baremetal `prdk8smin520` : à ajouter manuellement aux groupes `k8s_workers_lan` + `gpu`
  après la phase 11 — il hérite alors automatiquement de `clu_k8s_xkub`, `os_lin_r10`
  et `sys_net_lan`.
- `ansible_user: ansible-windows` défini au niveau `all`.

## Validation de la phase

- `terraform fmt -check`, `terraform validate`, `plan` puis `apply`.
- **Idempotence** : un second `terraform plan` doit afficher 0 changement.
- 11 VMs démarrées avec la bonne IP/hostname, SSH `ansible-windows@<fqdn>` OK partout.
- `hosts.yml` généré et valide (`ansible-inventory -i ... --graph`).

## Livrable cookbook

`../docs/cookbook/02-terraform-xen-orchestra.md`.
