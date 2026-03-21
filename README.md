# Jenkins Pipeline

Pipeline de CI/CD completo con Jenkins para aplicaciones containerizadas.

## Características

- **Multi-stage Pipeline**: Build, Test, Security Scan, Deploy
- **Docker Integration**: Build y push de imágenes
- **Security Scanning**: Trivy vulnerability scanner
- **Kubernetes Deployment**: Despliegue a staging y producción
- **Branch-based**: Estrategias para develop y main
- **Notifications**: Email alerts en cada ejecución

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

### Variables de Entorno

| Variable | Descripción | Default |
|----------|-------------|---------|
| DOCKER_REGISTRY | Registry Docker | docker.io |
| IMAGE_NAME | Nombre de imagen | myapp |
| VERSION | Versión | BUILD_NUMBER |

## Stages

1. **Checkout** -获取 código fuente
2. **Build** - Construir imagen Docker
3. **Test** - Ejecutar tests
4. **Security Scan** - Trivy vulnerability scan
5. **Deploy to Staging** - Despliegue automático (branch develop)
6. **Deploy to Production** - Despliegue manual (branch main)
7. **Notify** - Enviar notificaciones

## Seguridad

- Scanning de vulnerabilidades con Trivy
- No almacenar secretos en código
- Usar Jenkins credentials para tokens
- Aprobación manual para producción

## Contributing

1. Fork el repositorio
2. Crear branch feature
3. Commitear cambios
4. Push y crear PR

## License

MIT
