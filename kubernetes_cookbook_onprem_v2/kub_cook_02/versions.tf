terraform {
  required_version = ">= 1.6.0"

  required_providers {
    xenorchestra = {
      source  = "vatesfr/xenorchestra"
      version = "~> 0.39.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

# Authentification Xen Orchestra fournie EXCLUSIVEMENT via l'environnement :
#   XOA_URL    = "wss://prdxcpxor501.coolcorp.priv:8443"   (websocket, pas https)
#   XOA_TOKEN  = "<token XO>"
# Rien ne doit figurer ici ni dans git (cf. CLAUDE.md).
# `insecure` est passé explicitement : la variable d'env XOA_INSECURE n'est pas
# prise en compte de façon fiable par le provider 0.39.x.
# `retry_mode = "backoff"` : XAPI limite à 3 les migrations de stockage simultanées
# (TOO_MANY_STORAGE_MIGRATES) ; le provider réessaie au lieu d'échouer.
provider "xenorchestra" {
  insecure   = var.xoa_insecure
  retry_mode = "backoff"
}
