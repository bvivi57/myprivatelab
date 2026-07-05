#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# 20-cloud-init.sh — Configuration cloud-init pour le datasource NoCloud
# C'est ce datasource qu'utilise ensuite le provider Terraform xenorchestra
# (attributs cloud_config / cloud_network_config) pour injecter hostname/IP.
# ----------------------------------------------------------------------------
set -euxo pipefail

dnf -y install cloud-init

# Restreindre cloud-init au seul datasource NoCloud (évite les sondes inutiles)
cat > /etc/cloud/cloud.cfg.d/90-datasource.cfg <<'EOF'
datasource_list: [ NoCloud, None ]
EOF

systemctl enable cloud-init-local.service cloud-init.service cloud-config.service cloud-final.service
