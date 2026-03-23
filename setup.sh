#!/bin/bash
# jenkins-pipeline Setup Script
# Configura el entorno para el pipeline de Jenkins

set -euo pipefail

echo "🔄 Jenkins Pipeline - Configuración"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_jenkins() {
    if command -v jenkins &> /dev/null || [ -f "/usr/share/jenkins/jenkins.war" ]; then
        echo -e "${GREEN}✓ Jenkins encontrado${NC}"
    else
        echo -e "${YELLOW}⚠ Jenkins no instalado localmente (puede estar en contenedor)${NC}"
    fi
}

check_docker() {
    if command -v docker &> /dev/null; then
        echo -e "${GREEN}✓ Docker encontrado${NC}"
        docker --version
    else
        echo -e "${RED}✗ Docker no encontrado${NC}"
        exit 1
    fi
}

check_kubectl() {
    if command -v kubectl &> /dev/null; then
        echo -e "${GREEN}✓ kubectl encontrado${NC}"
    else
        echo -e "${YELLOW}⚠ kubectl no encontrado (necesario para K8s)${NC}"
    fi
}

check_grype() {
    if command -v grype &> /dev/null; then
        echo -e "${GREEN}✓ Grype encontrado${NC}"
    else
        echo -e "${YELLOW}⚠ Grype no encontrado (instalando...)"
        curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh
        echo -e "${GREEN}✓ Grype instalado${NC}"
    fi
}

check_checkov() {
    if command -v checkov &> /dev/null; then
        echo -e "${GREEN}✓ Checkov encontrado${NC}"
    else
        echo -e "${YELLOW}⚠ Checkov no encontrado${NC}"
        echo "  pip install checkov  # Para escaneo de IaC"
    fi
}

main() {
    echo "Verificando dependencias..."
    check_jenkins
    check_docker
    check_kubectl
    check_grype
    check_checkov
    
    echo ""
    echo "======================================"
    echo -e "${GREEN}✓ Configuración completada!${NC}"
    echo "======================================"
    echo ""
    echo "Para ejecutar el pipeline:"
    echo "  jenkinsfile-conventions"  # Configurar credenciales
    echo "  docker build -t myapp ."
    echo ""
    echo "Variables requeridas:"
    echo "  JENKINS_URL, JENKINS_USER, JENKINS_TOKEN"
    echo "  DOCKER_REGISTRY, KUBECONFIG"
}

main "$@"
