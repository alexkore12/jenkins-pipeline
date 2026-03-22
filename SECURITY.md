# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | ✅                 |

## Reporting a Vulnerability

If you discover a security vulnerability within this pipeline, please send an e-mail to the maintainer. All security vulnerabilities will be promptly addressed.

Please include the following information:

- Type of vulnerability
- Full paths of source file(s)
- Location of the affected source code
- Any special configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue

## Security Best Practices for Jenkins Pipelines

### Credentials Management

- Use Jenkins credentials API for storing secrets
- Never hardcode credentials in pipeline scripts
- Use `withCredentials` block for secure credential access
- Rotate credentials periodically

### Pipeline Security

- Enable script approval for Groovy scripts
- Use declarative pipelines when possible
- Avoid `sh` with user input
- Sanitize all parameters

### Plugin Security

- Keep Jenkins and plugins updated
- Review installed plugins regularly
- Remove unused plugins
- Use trusted plugins only

### Network Security

- Use HTTPS for all connections
- Configure firewall rules appropriately
- Limit exposed endpoints
- Implement rate limiting

## Security Scanning

This pipeline includes security scanning steps:

- ✅ Container vulnerability scanning (Grype)
- ✅ IaC validation (Checkov)
- ✅ Dependency scanning
- ✅ Secret detection

---

*Last updated: 2026-03-22*
