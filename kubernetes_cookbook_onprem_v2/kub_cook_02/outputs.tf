# Génère l'inventaire Ansible consommé en phase 3.
# Méthode : yamlencode() (YAML toujours valide) plutôt qu'un templatefile,
# pour garantir que `ansible-inventory --graph` parse le fichier sans surprise
# de mise en forme. Le baremetal prdk8smin520 reste à ajouter à la main.
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../xkub.coolcorp.priv.ansible/inventory/hosts.yml"
  # local_file crée en 0777 par défaut : un inventaire n'a pas à être exécutable.
  file_permission = "0644"
  content         = <<-EOT
    # ------------------------------------------------------------------
    # Inventaire Ansible GÉNÉRÉ par Terraform (phase 2) — NE PAS éditer.
    # Régénéré à chaque `terraform apply`.
    # Baremetal prdk8smin520 (GPU) : à ajouter MANUELLEMENT aux groupes
    # k8s_workers_lan ET gpu après la phase 11 — il héritera alors
    # automatiquement des groupes transverses clu_k8s_xkub, os_lin_r10
    # et sys_net_lan.
    # ------------------------------------------------------------------
    ${yamlencode(local.inventory)}
  EOT
}

output "deployed_nodes" {
  description = "Récapitulatif des VMs déclarées (hostname => IP)."
  value       = { for name, n in var.nodes : name => n.ip }
}

output "vm_ids" {
  description = "IDs Xen Orchestra des VMs créées."
  value       = { for k, m in module.node : k => m.vm_id }
}
