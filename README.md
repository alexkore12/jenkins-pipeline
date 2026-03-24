# Jenkins Pipeline

> Pipeline de CI/CD completo con Jenkins para aplicaciones containerizadas con seguridad integrada y despliegues Kubernetes.

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Jenkins](https://img.shields.io/badge/Jenkins-2.x-red.svg)](Jenkinsfile)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://docker.com)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Ready-blue.svg)](deploy/)
[![Security: Grype](https://img.shields.io/badge/Security-Grype-orange.svg)](.grype.yaml)

> ⚠️ **Marzo 2026**: Trivy comprometido por supply chain attack.
> Este pipeline usa **Grype** y **Checkov** como alternativas seguras.

## 📋 Descripción

Pipeline declarativo Jenkins que automatiza el ciclo completo de CI/CD: build, test, security scanning, y deployment a Kubernetes con estrategias branch-based y quality gates.

## ✨ Características

- ✅ **Multi-stage Pipeline** - Build → Test → Security → Deploy
- ✅ **Docker Integration** - Build y push automatizado
- ✅ **Security Scanning** - Grype + Checkov
- ✅ **Kubernetes Deploy** - Staging y Production
- ✅ **Branch-based** - develop → staging, main → production
- ✅ **Quality Gates** - Validación de coverage y vulnerabilidades
- ✅ **Notifications** - Email y Slack
- ✅ **Supply Chain Security** - Verificación de integridad
- ✅ **Artifact Management** - Versionado y rollback

## 🚀 Instalación

### Prerequisites

- Jenkins 2.x con plugins:
  - Pipeline
  - Docker Pipeline
  - Kubernetes CLI
  - Git
  - JUnit
  - Email Extension
  
- Docker 20.x+
- kubectl configurado
- Grype y Checkov instalados

### Configuración

```bash
# Clonar repositorio
git clone https://github.com/alexkore12/jenkins-pipeline.git
cd jenkins-pipeline

# Verificar herramientas
make verify

# Help
make help
```

### Jenkins Setup

1. **Nueva Pipeline:**
   - Dashboard → New Item → Pipeline
   - Nombre: `app-pipeline`
   - Pipeline script from SCM

2. **Configurar SCM:**
   ```
   Repository: https://github.com/alexkore12/jenkins-pipeline.git
   Branch: */main
   Script Path: Jenkinsfile
   ```

3. **Credenciales requeridas:**
   - `docker-hub` - Docker Registry
   - `kubeconfig` - Kubernetes config
   - `slack-webhook` - Slack notifications
   - `smtp` - Email notifications

## 📁 Estructura

```
jenkins-pipeline/
├── Jenkinsfile                    # Pipeline principal
├── Dockerfile                     # Imagen de la app
├── docker-compose.yml             # Desarrollo local
├── Makefile                       # Comandos útiles
├── deploy/
│   ├── staging.yaml               # Staging K8s
│   └── production.yaml            # Production K8s
├── scripts/
│   ├── notify.sh                  # Notificaciones
│   └── rollback.sh                # Rollback script
├── .github/
│   └── workflows/
│       └── github-actions.yml     # GitHub Actions (backup)
├── .env.example
├── .grype.yaml                   # Grype config
├── SECURITY.md
├── PIPELINE_GUIDE.md
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── LICENSE
└── README.md
```

## 🔄 Pipeline Stages

```
┌────────────────────────────────────────────────────────────────┐
│                         PIPELINE                                │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  [Checkout] → [Build] → [Test] → [Security Scan] → [Quality]  │
│                                                            │    │
│                                                            ▼    │
│  [Notify] ← [Deploy Prod] ← [Approval] ← [Deploy Staging]     │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

### Stage Details

| Stage | Descripción | Tiempo |
|-------|-------------|--------|
| Checkout | Git clone | 5s |
| Build | Docker build | 2-5min |
| Test | Unit tests | 1-3min |
| Security Scan | Grype + Checkov | 30s-2min |
| Push | Docker push | 1-3min |
| Deploy Staging | kubectl apply | 1-2min |
| Approval | Manual approval | Variable |
| Deploy Production | kubectl apply | 2-3min |

## 🐳 Comandos

```bash
make build          # Construir imagen
make test           # Ejecutar tests
make scan           # Security scan
make push           # Push a registry
make deploy-staging  # Deploy a staging
make deploy-prod     # Deploy a producción
make rollback        # Rollback
make logs           # Ver logs
make clean          # Limpiar
```

## 🔐 Seguridad

### Alternatives a Trivy

| Herramienta | Uso |
|-------------|-----|
| **Grype** | Escaneo de vulnerabilidades de imágenes |
| **Checkov** | Escaneo de IaC (K8s, Terraform, Docker) |

### Environment

```bash
export DOCKER_REGISTRY=docker.io
export DOCKER_USERNAME=usuario
export DOCKER_PASSWORD=password
export KUBECONFIG=/path/to/config
export SLACK_WEBHOOK=https://hooks.slack.com/...
export ALERT_THRESHOLD=CRITICAL
```

## 📊 GitHub Actions (Backup)

Workflow alternativo en `.github/workflows/github-actions.yml`:

- Trigger: push a develop → staging, push a main → production
- Ejecuta: lint, test, build, scan, deploy

## 📖 Guía Completa

Ver [PIPELINE_GUIDE.md](PIPELINE_GUIDE.md) para:
- Configuración detallada
- Troubleshooting
- Mejores prácticas
- Examples

## 🤝 Contribuir

1. Fork → Branch → Commit → PR
2. Tests deben pasar
3. Security scan limpio
4. Documentación actualizada

## 📄 Licencia

MIT - ver [LICENSE](LICENSE)
