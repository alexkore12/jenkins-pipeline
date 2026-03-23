# Makefile for jenkins-pipeline
# Common development tasks

.PHONY: help validate lint security-scan deploy-staging deploy-production clean

help:
	@echo "Available commands:"
	@echo "  make validate          - Validate Jenkinsfile syntax"
	@echo "  make lint              - Lint Kubernetes YAML files"
	@echo "  make security-scan     - Run Grype security scan"
	@echo "  make deploy-staging   - Deploy to staging"
	@echo "  make deploy-production - Deploy to production"
	@echo "  make clean             - Clean temporary files"

validate:
	jenkins-cli validate Jenkinsfile || echo "Install jenkins-cli for validation"

lint:
	kubeval deploy/*.yaml || helm lint deploy/

security-scan:
	grype . --config .grype.yaml || true

deploy-staging:
	kubectl apply -f deploy/staging.yaml

deploy-production:
	kubectl apply -f deploy/production.yaml

clean:
	find . -name "*.log" -delete
	rm -rf .gradle/ 2>/dev/null || true
