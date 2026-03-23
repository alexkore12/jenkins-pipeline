# Jenkins Pipeline

Pipeline de CI/CD completo con Jenkins para aplicaciones containerizadas con seguridad integrada.

> ⚠️ **Marzo 2026**: Trivy comprometido por supply chain attack (2° ataque).
> Este pipeline ahora usa **Grype** (alternativa a Trivy) y **Checkov**.

## Características

- ✅ **Multi-stage Pipeline** - Build, Test, Security Scan, Deploy
- ✅ **Docker Integration** - Build y push de imágenes
- ✅ **Security Scanning** - Grype vulnerability scanner + Checkov for IaC
- ✅ **Kubernetes** - Despliegue a staging y producción
- ✅ **Branch-based** - Estrategias para develop y main
- ✅ **Notifications** - Alertas por email y Slack
- ✅ **Supply Chain** - Verificación de integridad

## Alternativas a Trivy

Este pipeline usa alternativas seguras:

- **Grype**: Escaneo de vulnerabilidades de contenedores
- **Checkov**: Escaneo de infraestructura como código (Terraform, K8s, Docker)

## Estructura

```
jenkins-pipeline/
├── Jenkinsfile                    # Pipeline declarativo
├── Dockerfile                     # Imagen de la aplicación
├── deploy/
│   ├── staging.yaml               # Manifiestos K8s staging
│   └── production.yaml            # Manifiestos K8s production
├── scripts/
│   └── notify.sh                  # Scripts de notificación
└── .github/
    └── workflows/
        └── github-actions.yml     # GitHub Actions (alternativo)
```

## Diagrama del Pipeline

```
┌─────────────┐ ┌──────────┐ ┌─────────┐ ┌──────────────┐
│ Checkout    │──▶│ Build    │──▶│ Test    │──▶│Security Scan │
└─────────────┘ └──────────┘ └─────────┘ └──────────────┘
                                                │
                                                ▼
┌─────────────┐ ┌─────────────┐ ┌────────────┐ ┌──────────────┐
│ Notify      │◀──│ Deploy     │◀──│ Approve   │◀──│ Scan         │
│             │   │Production  │   │           │   │ Staging      │
└─────────────┘ └─────────────┘ └────────────┘ └──────────────┘
```

## Validación Local

```bash
# Jenkins CLI
jenkins-cli validate Jenkinsfile

# Local con Docker
docker build -t myapp:test .
```

## Configuración en Jenkins

1. Crear nuevo Pipeline job
2. Apuntar a este repositorio
3. Configurar GitHub webhook
4. Instalar plugins necesarios:

### Plugins Requeridos

- Pipeline
- Docker
- Kubernetes
- Email Extension
- Slack Notification

## Variables de Entorno

| Variable | Descripción | Default |
|----------|-------------|---------|
| `DOCKER_REGISTRY` | Registry Docker | docker.io |
| `IMAGE_NAME` | Nombre de imagen | myapp |
| `VERSION` | Versión | BUILD_NUMBER |
| `GRYPE_VERSION` | Versión de Grype | 0.80.0 |
| `SEVERITY_THRESHOLD` | Umbral | HIGH,CRITICAL |

## Stages del Pipeline

```groovy
// Checkout
stage('Checkout') {
    steps {
        checkout scm
    }
}

// Build
stage('Build') {
    steps {
        sh 'docker build -t ${IMAGE}:${VERSION} .'
    }
}

// Test
stage('Test') {
    steps {
        sh 'npm test -- --coverage'
    }
}

// Security Scan (Grype)
stage('Security Scan') {
    steps {
        sh 'grype ${IMAGE}:${VERSION} --severity HIGH,CRITICAL'
    }
}

// Deploy Staging
stage('Deploy Staging') {
    steps {
        sh 'kubectl apply -f deploy/staging.yaml'
    }
}

// Deploy Production
stage('Deploy Production') {
    when {
        branch 'main'
    }
    steps {
        input 'Deploy to Production?'
        sh 'kubectl apply -f deploy/production.yaml'
    }
}
```

## Dockerfile

```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["node", "index.js"]
```

## Kubernetes Manifests

### Staging

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-staging
spec:
  replicas: 2
  selector:
    matchLabels:
      app: myapp
      env: staging
  template:
    spec:
      containers:
        - name: myapp
          image: myapp:staging
          ports:
            - containerPort: 3000
```

### Production

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-production
spec:
  replicas: 4
  strategy:
    type: RollingUpdate
  selector:
    matchLabels:
      app: myapp
      env: production
  template:
    spec:
      containers:
        - name: myapp
          image: myapp:latest
          ports:
            - containerPort: 3000
          resources:
            limits:
              cpu: "500m"
              memory: "512Mi"
```

## Notificaciones

### Email

```groovy
post {
    failure {
        emailext subject: "Jenkins: ${currentBuild.result}",
        body: "Pipeline failed: ${env.BUILD_URL}",
        to: "team@example.com"
    }
    success {
        emailext subject: "Jenkins: Success",
        body: "Build successful: ${env.BUILD_URL}",
        to: "team@example.com"
    }
}
```

### Slack

```groovy
post {
    success {
        slackSend channel: '#deployments',
        color: 'good',
        message: "Deployment successful: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
    }
}
```

## Mejores Prácticas de Seguridad

- ❌ No hardcoded secrets - Usar Jenkins credentials
- ✅ Scan images - Grype en cada build
- ✅ SBOM - Generar Software Bill of Materials
- ✅ Sign images - Usar Cosign
- ✅ Readonly root filesystem - En producción
- ✅ Run as non-root - En contenedores

## GitHub Actions (Alternativo)

El proyecto también incluye GitHub Actions como alternativa:

```yaml
name: CI/CD

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build
        run: docker build -t myapp .
      - name: Scan
        uses: anchore/grype-action@v0.17.0
        with:
          image: myapp
      - name: Deploy
        run: kubectl apply -f deploy/
```

## Changelog

- ✅ v2.1.0 - GitHub Actions añadido, Grype替换Trivy
- ✅ v2.0.0 - Multi-branch pipeline
- ✅ v1.2.0 - Kubernetes deployment
- ✅ v1.1.0 - Security scanning
- ✅ v1.0.0 - Basic pipeline

## Licencia

MIT License

## Autor

GitHub: [alexkore12](https://github.com/alexkore12)

Este proyecto fue actualizado por OpenClaw AI Assistant - 2026-03-22

## 🌐 Referencias

- [Documentación de Jenkins](https://www.jenkins.io/doc/)
- [Grype Vulnerability Scanner](https://github.com/anchore/grype)
- [Checkov](https://www.checkov.io/)
- [Kubernetes Docs](https://kubernetes.io/docs/)
