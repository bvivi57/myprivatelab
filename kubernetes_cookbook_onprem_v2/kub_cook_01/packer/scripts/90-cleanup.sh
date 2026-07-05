#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# 90-cleanup.sh — Généralisation du template (DOIT être le dernier provisioner)
# Objectif : chaque clone obtient un machine-id, des clés SSH hôte et un seed
# cloud-init uniques. Sans ça, tous les clones partageraient la même identité.
# ----------------------------------------------------------------------------
set -euxo pipefail

# Effacer les profils réseau du build (connexion DHCP créée par l'installeur) : le
# template reste générique. Chaque clone reçoit son réseau via cloud-init NoCloud
# (provider Terraform xenorchestra, phase 2), sans hériter d'un profil du build.
rm -f /etc/NetworkManager/system-connections/*
rm -f /etc/sysconfig/network-scripts/ifcfg-*

# Réinitialiser cloud-init (seed + logs) pour qu'il rejoue au 1er boot du clone
cloud-init clean --logs --seed || true

# machine-id régénéré au prochain boot
truncate -s 0 /etc/machine-id
# /var/lib/dbus/machine-id : compat ancienne ; sur Rocky 10 minimal le dossier
# /var/lib/dbus n'existe pas (systemd/dbus-broker lit directement /etc/machine-id).
# Ne recréer le lien que si le dossier existe, sinon le build échoue (set -e).
if [ -d /var/lib/dbus ]; then
  rm -f /var/lib/dbus/machine-id
  ln -sf /etc/machine-id /var/lib/dbus/machine-id
fi

# Clés d'hôte SSH régénérées au 1er boot (unités sshd-keygen de Rocky)
rm -f /etc/ssh/ssh_host_*

# Caches et journaux
dnf clean all
rm -rf /var/cache/dnf/* /tmp/* /var/tmp/*
find /var/log -type f -exec truncate -s 0 {} \;
rm -f /root/ks-post.log

# Historique shell
: > /root/.bash_history || true
: > /home/ansible-windows/.bash_history || true
