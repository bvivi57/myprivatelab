#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# 10-guest-tools.sh — Guest tools XCP-ng + mise à jour système
# PIÈGE EL10 : sur Rocky Linux 10, xe-guest-utilities n'est PAS dans les dépôts
# de base. Le paquet 'xe-guest-utilities-latest' est fourni par EPEL 10.
# Sans ces guest tools, XO/Terraform ne remontent pas l'IP des VMs.
# ----------------------------------------------------------------------------
set -euxo pipefail

dnf -y update

# EPEL pour disposer de xe-guest-utilities-latest
dnf -y install epel-release
dnf -y install xe-guest-utilities-latest

# Agent invité Xen : sur EL10, xe-linux-distribution.service EST le service principal
# (il lance le démon xe-daemon, qui remonte l'IP/metrics vers XenStore → lues par XO et
# Terraform en phase 2). Il n'existe PAS de xe-daemon.service séparé. On enable sans
# « || true » : si ça échoue, on veut que le build s'arrête (guest tools = critiques).
systemctl enable xe-linux-distribution.service
