# 🔄 Jenkins Pipeline

Pipeline de CI/CD completo con Jenkins para aplicaciones containerizadas con seguridad integrada.

## ⚠️ Aviso de Seguridad - Trivy

**Marzo 2026:** Trivy comprometido por supply chain attack (2° ataque).

**Este pipeline ahora usa Grype** (alternativa a Trivy):
- Grype: Escaneo de vulnerabilidades
- Checkov: Escaneo de infraestructura como código

## 📋 Descripción

Pipeline declarativo Jenkins que automatiza el ciclo de vida completo:
- Build → Test → Security Scan → Deploy

## 🚀 Características

- ✅ **Multi-stage Pipeline** - Build, Test, Security Scan, Deploy
- ✅ **Docker Integration** - Build y push de imágenes
- ✅ **Security Scanning** - Grype vulnerability scanner (replaced Trivy)
- ✅ **Kubernetes** - Despliegue a staging y producción
- ✅ **Branch-based** - Estrategias para develop y main
- ✅ **Notifications** - Alertas por email y Slack
- ✅ **Supply Chain** - Verificación de integridad

## 📁 Estructura

```
jenkins-pipeline/
├── Jenkinsfile          # Pipeline declarativo
├── Dockerfile          # Imagen de la aplicación
├── deploy/
│   ├── staging.yaml    # Manifiestos K8s staging
│   └── production.yaml # Manifiestos K8s production
└── scripts/
    └── notify.sh       # Scripts de notificación
```

## 📊 Pipeline Stages

```
┌─────────────┐    ┌──────────┐    ┌─────────┐    ┌──────────────┐
│  Checkout   │───▶│   Build   │───▶│  Test   │───▶│Security Scan │
└─────────────┘    └──────────┘    └─────────┘    └──────────────┘
                                                        │
                                                        ▼
┌─────────────┐    ┌─────────────┐    ┌────────────┐    ┌──────────────┐
│   Notify    │◀───│  Deploy    │◀───│  Approve   │◀───│    Scan     │
│             │    │Production  │    │            │    │  Staging    │
└─────────────┘    └─────────────┘    └────────────┘    └──────────────┘
```

## 🚀 Uso

### Validar Jenkinsfile

```bash
# Jenkin CLI
jenkins-cli validate Jenkinsfile

# Local con Docker
docker build -t myapp:test .
```

### Configurar Jenkins

1. Crear nuevo Pipeline job
2. Apuntar a este repositorio
3. Configurar GitHub webhook
4. Instalar plugins necesarios:
   - Pipeline
   - Docker
   - Kubernetes
   - Trivy
   - Email Extension

### Variables de Entorno

| Variable | Descripción | Default |
|----------|-------------|---------|
| `DOCKER_REGISTRY` | Registry Docker | docker.io |
| `IMAGE_NAME` | Nombre de imagen | myapp |
| `VERSION` | Versión | BUILD_NUMBER |
| `TRIVY_VERSION` | Versión de Trivy | 0.57.0 |
| `SEVERITY_THRESHOLD` | Umbral | HIGH,CRITICAL |

## 📝 Stages Detallados

### 1. Checkout
```groovy
stage('Checkout') {
    steps {
        checkout scm
    }
}
```

### 2. Build
```groovy
stage('Build') {
    steps {
        sh 'docker build -t ${IMAGE}:${VERSION} .'
    }
}
```

### 3. Test
```groovy
stage('Test') {
    steps {
        sh 'npm test -- --coverage'
    }
}
```

### 4. Security Scan
```groovy
stage('Security Scan') {
    steps {
        sh 'trivy image --severity HIGH,CRITICAL ${IMAGE}:${VERSION}'
    }
}
```

### 5. Deploy Staging
```groovy
stage('Deploy Staging') {
    steps {
        sh 'kubectl apply -f deploy/staging.yaml'
    }
}
```

### 6. Deploy Production
```groovy
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

## 🐳 Docker

### Dockerfile

```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["node", "index.js"]
```

### Build Manual

```bash
docker build -t myapp:latest .
docker push myapp:latest
```

## ☸️ Kubernetes

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

## 🔔 Notificaciones

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

## 🛡️ Security Best Practices

1. **No hardcoded secrets** - Usar Jenkins credentials
2. **Scan images** - Trivy en cada build
3. **SBOM** - Generar Software Bill of Materials
4. **Sign images** - Usar Cosign
5. **Readonly root filesystem** - En producción
6. **Run as non-root** - En contenedores

## 📋 Changelog

- **v2.0.0** - Multi-branch pipeline
- **v1.2.0** - Kubernetes deployment
- **v1.1.0** - Security scanning
- **v1.0.0** - Basic pipeline

## 🤝 Contribución

¡Mejoras bienvenidas! Abre un issue o PR.

## 📄 Licencia

MIT License
