# Jenkins Pipeline

Pipeline de CI/CD completo con Jenkins para aplicaciones containerizadas.

## ⚠️ Aviso de Seguridad Importante

**Marzo 2026:** Se ha detectado un ataque de supply chain en Trivy. Recomendaciones:

1. Verificar la integridad de las imágenes de Trivy usadas en el pipeline
2. Usar firmas digitales para verificar binarios
3. Mantener Trivy actualizado a la última versión parcheada
4. Implementar escaneo en múltiples etapas del pipeline

## Características

- **Multi-stage Pipeline**: Build, Test, Security Scan, Deploy
- **Docker Integration**: Build y push de imágenes
- **Security Scanning**: Trivy vulnerability scanner
- **Kubernetes Deployment**: Despliegue a staging y producción
- **Branch-based**: Estrategias para develop y main
- **Notifications**: Email alerts en cada ejecución
- **Supply Chain Security**: Verificación de integridad de dependencias

## Estructura

```
jenkins-pipeline/
├── Jenkinsfile          # Pipeline declarativo
├── Dockerfile          # Imagen de la aplicación
├── deploy/
│   ├── staging.yaml    # Manifiestos Kubernetes staging
│   └── production.yaml # Manifiestos Kubernetes production
└── scripts/
    └── notify.sh       # Scripts de notificación
```

## Pipeline Stages

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

## Uso

### Desarrollo Local

```bash
# Validar Jenkinsfile
jenkins-cli validate Jenkinsfile

# Simular build local
docker build -t myapp:test .
```

### Configuración Jenkins

1. Crear nuevo Pipeline job
2. Point to this repository
3. Configure GitHub webhook para triggers
4. Instalar plugin de Trivy (opcional)

### Variables de Entorno

| Variable | Descripción | Default |
|----------|-------------|---------|
| DOCKER_REGISTRY | Registry Docker | docker.io |
| IMAGE_NAME | Nombre de imagen | myapp |
| VERSION | Versión | BUILD_NUMBER |
| TRIVY_VERSION | Versión de Trivy | 0.57.0 |
| SEVERITY_THRESHOLD | Umbral de severidad | HIGH,CRITICAL |

## Stages Detallados

### 1. Checkout
- Obtiene código fuente del repositorio
- Configura credenciales si es necesario

### 2. Build
- Construye imagen Docker
- Usa BuildKit para builds más rápidos
- Cache de capas habilitado

### 3. Test
- Ejecuta tests unitarios
- Coverage report
- Fail si coverage < 80%

### 4. Security Scan (Trivy)
```groovy
stage('Security Scan') {
    steps {
        script {
            sh '''
                trivy image --severity HIGH,CRITICAL \
                    --exit-code 1 \
                    --ignore-unfixed \
                    ${IMAGE}:${VERSION}
            '''
        }
    }
}
```

### 5. Deploy to Staging
- Automático en branch `develop`
- Actualiza imagen en registry
- Despliega a namespace staging

### 6. Deploy to Production
- Requiere aprobación manual
- Solo en branch `main`
- Blue-green deployment opcional

### 7. Notify
- Envía notificación a Slack/Teams
- Incluye resultado del scan de seguridad

## Seguridad

### Supply Chain Security

```groovy
// Verificar imagen base
stage('Verify Base Image') {
    steps {
        sh '''
            cosign verify docker.io/library/alpine:latest || \
                echo "Warning: Cannot verify base image"
        '''
    }
}
```

- Scanning de vulnerabilidades con Trivy
- Verificación de firmas (cosign)
- No almacenar secretos en código
- Usar Jenkins credentials para tokens
- Aprobación manual para producción
- SBOM (Software Bill of Materials) generation

### Mejores Prácticas

1. **No ejecutar como root** en contenedores
2. **Usar usuarios no privilegiados**
3. **Escanear dependencias** (npm audit, pip-audit)
4. **Validar registros** de contenedores
5. **Rotar credenciales** regularmente

## Kubernetes Integration

### Staging Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-staging
  namespace: staging
spec:
  replicas: 2
  template:
    spec:
      containers:
      - name: myapp
        image: myapp:staging
```

### Production Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-production
  namespace: production
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
  template:
    spec:
      containers:
      - name: myapp
        image: myapp:production
```

## Troubleshooting

### Pipeline falla en Security Scan

1. **Verificar versión de Trivy**: ¿Es la última?
2. **Revisar vulnerabilidades**: ¿Son reales o false positives?
3. **Ignorar Fixed**: Usar `--ignore-unfixed`
4. **Exceptions**: Documentar en JIRA si es falso positivo

### Build lento

1. Habilitar caching de Docker
2. Usar BuildKit
3. Multi-stage builds

## Contributing

1. Fork el repositorio
2. Crear branch feature
3. Commitear cambios
4. Push y crear PR
5. Asegurar que Security Scan passe

## Monitoreo

Este pipeline genera métricas:

- **Build duration**: Tiempo de ejecución
- **Test coverage**: Porcentaje de cobertura
- **Vulnerabilities found**: CVEs detectados
- **Deployment frequency**: Frecuencia de despliegues

## License

MIT
