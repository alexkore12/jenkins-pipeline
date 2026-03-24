# 🤝 Guía de Contribución

¡Gracias por tu interés en contribuir! Este documento outline el proceso para contribuir a este pipeline.

## 📋 Tabla de Contenidos

- [Código de Conducta](#código-de-conducta)
- [Cómo Contribuir](#cómo-contribuir)
- [Estándares de Código](#estándares-de-código)
- [Pipeline Stages](#pipeline-stages)
- [Testing](#testing)
- [Security](#security)

## Código de Conducta

Participa de forma respetuosa. No toleramos discriminación ni acoso.

## Cómo Contribuir

### Issues

- 🐛 **Bug Reports**: Incluir pasos para reproducir, logs, ambiente
- 💡 **Feature Requests**: Descripción clara, use cases, mockups si aplica
- 📖 **Documentation**: Mejoras de docs, typos, ejemplos

### Pull Requests

1. **Fork** el repositorio
2. **Branch**: `git checkout -b feature/nueva-caracteristica`
3. **Commit**: Mensajes descriptivos siguiendo Conventional Commits
4. **Push**: `git push origin feature/nueva-caracteristica`
5. **PR**: Complete el template de PR

### Formato de Commits

```
feat: nueva característica
fix: corrección de bug
docs: cambios en documentación  
style: formato (sin cambio de lógica)
refactor: refactorización
test: agregar o modificar tests
chore: mantenimiento, deps, configuración
security: cambios de seguridad
```

## Estándares de Código

### Jenkinsfile

```groovy
// Usar.pipelineDeclarativo
pipeline {
    agent any
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 1, unit: 'HOURS')
        disableConcurrentBuilds()
    }
    
    stages {
        stage('Build') {
            steps {
                echo 'Building...'
            }
        }
    }
}
```

### Shell Scripts

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Constants
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="${LOG_FILE:-/tmp/pipeline.log}"
```

## Pipeline Stages

### Agregar Nuevo Stage

```groovy
stage('Custom Stage') {
    steps {
        script {
            echo "Executing custom stage"
        }
    }
    post {
        always {
            echo "Cleanup or notifications"
        }
        success {
            echo "Stage succeeded"
        }
        failure {
            echo "Stage failed"
        }
    }
}
```

### Condicional Stages

```groovy
stage('Deploy Production') {
    when {
        branch 'main'
        expression { env.DEPLOY_TO_PROD == 'true' }
    }
    steps {
        echo "Deploying to production..."
    }
}
```

## Testing

### Unit Tests

```bash
# Ejecutar localmente
make test

# Con verbose
make test-verbose

# Coverage
make test-coverage
```

### Integration Tests

```bash
# Ejecutar en ambiente de staging
make test-integration ENV=staging
```

### Security Scan

```bash
# Grype scan
make scan

# Con threshold
SCAN_THRESHOLD=CRITICAL make scan
```

## Security

### Secrets

- ❌ Nunca commitear secrets
- ✅ Usar Jenkins credentials
- ✅ Environment variables cifradas
- ✅ Kubernetes secrets

### Vulnerabilidades

| Severidad | Acción |
|-----------|--------|
| CRITICAL | Bloquea deployment |
| HIGH | Warning + approval manual |
| MEDIUM | Warning |
| LOW | Info only |

## Code Review

- Mínimo 1 approval
- Todos los checks deben pasar
- Sin conflictos con main
- Documentación actualizada

## 📧 Preguntas

Para preguntas, abrir issue o contactar al maintainer.

---

¡Gracias por contribuir! 🙏
