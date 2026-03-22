# Jenkins Pipeline Best Practices Guide

## Table of Contents
1. [Pipeline Structure](#pipeline-structure)
2. [Security](#security)
3. [Testing](#testing)
4. [Deployment](#deployment)
5. [Monitoring](#monitoring)

## Pipeline Structure

### Basic Pipeline Template

```groovy
pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'registry.example.com'
        APP_NAME = 'my-app'
        DEPLOY_ENV = 'staging'
    }
    
    options {
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                script {
                    sh 'make build'
                }
            }
        }
        
        stage('Test') {
            steps {
                parallel(
                    'Unit Tests': { sh 'make test-unit' },
                    'Integration Tests': { sh 'make test-integration' }
                )
            }
        }
        
        stage('Security Scan') {
            steps {
                script {
                    def scanResults = securityScan()
                    if (scanResults.failed) {
                        unstable('Security issues found')
                    }
                }
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                sh 'make deploy ENV=staging'
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            slackSend(color: 'good', message: "Build succeeded: ${env.JOB_NAME}")
        }
        failure {
            slackSend(color: 'danger', message: "Build failed: ${env.JOB_NAME}")
        }
    }
}
```

## Security

### Secrets Management

```groovy
pipeline {
    stages {
        stage('Deploy') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-secret', variable: 'AWS_SECRET'),
                    string(credentialsId: 'docker-token', variable: 'DOCKER_TOKEN')
                ]) {
                    sh '''
                        echo $AWS_SECRET | aws configure set secret_access_key --
                        docker login -u user -p $DOCKER_TOKEN registry.example.com
                    '''
                }
            }
        }
    }
}
```

### Input Validation

```groovy
def validateInput(String envName) {
    def validEnvs = ['dev', 'staging', 'production']
    if (!validEnvs.contains(envName)) {
        error "Invalid environment: ${envName}. Valid: ${validEnvs}"
    }
}

pipeline {
    parameters {
        choice(name: 'DEPLOY_ENV', choices: ['dev', 'staging', 'production'])
    }
    
    stages {
        stage('Deploy') {
            steps {
                script {
                    validateInput(params.DEPLOY_ENV)
                }
            }
        }
    }
}
```

## Testing

### Test Coverage

```groovy
stage('Test Coverage') {
    steps {
        sh 'make coverage'
        
        publishHTML([
            allowMissing: false,
            alwaysLinkToLastBuild: true,
            keepAll: true,
            reportDir: 'coverage/html',
            reportFiles: 'index.html',
            reportName: 'Coverage Report'
        ])
        
        jacoco(
            execPattern: '**/target/jacoco.exec',
            classPattern: '**/target/classes',
            sourcePattern: 'src/main/java',
            exclusionPattern: '**/*Test.class'
        )
    }
}
```

### Integration Tests

```groovy
stage('Integration Tests') {
    steps {
        script {
            // Start test containers
            docker-compose up -d db test-redis test-elasticsearch
            
            // Wait for services
            sh 'sleep 10'
            
            // Run tests
            try {
                sh 'make test-integration'
            } finally {
                // Cleanup
                docker-compose down -v
            }
        }
    }
}
```

## Deployment

### Blue-Green Deployment

```groovy
def deployBlueGreen(String environment, String version) {
    def activeColor = getActiveColor(environment)
    def inactiveColor = activeColor == 'blue' ? 'green' : 'blue'
    
    // Deploy to inactive
    sh """
        kubectl set image deployment/app-${inactiveColor} \
            app=myregistry.com/app:${version}
    """
    
    // Wait for deployment
    sh "kubectl rollout status deployment/app-${inactiveColor} -n ${environment}"
    
    // Test inactive
    def inactiveUrl = getServiceUrl(environment, inactiveColor)
    def testResult = curlTests(inactiveUrl)
    
    if (testResult.success) {
        // Switch traffic
        sh "kubectl patch service app -n ${environment} \
            -p '{\"spec\":{\"selector\":{\"color\":\"${inactiveColor}\"}}}'"
        
        // Keep old version for rollback
        sh "kubectl label deployment/app-${activeColor} \
            history-keep=true -n ${environment}"
    } else {
        error "Tests failed on ${inactiveColor}, rolling back"
    }
}
```

### Rollback

```groovy
pipeline {
    parameters {
        booleanParam(name: 'ROLLBACK', defaultValue: false)
    }
    
    stages {
        stage('Deploy') {
            when {
                expression { !params.ROLLBACK }
            }
            steps {
                sh 'make deploy'
            }
        }
        
        stage('Rollback') {
            when {
                expression { params.ROLLBACK }
            }
            steps {
                script {
                    sh "kubectl rollout undo deployment/app -n ${DEPLOY_ENV}"
                    sh "kubectl rollout status deployment/app -n ${DEPLOY_ENV}"
                }
            }
        }
    }
}
```

## Monitoring

### Health Checks

```groovy
def checkHealth(String url, int maxRetries = 3) {
    for (int i = 0; i < maxRetries; i++) {
        def response = sh(
            script: "curl -sf ${url}/health || true",
            returnStdout: true
        ).trim()
        
        if (response == 'OK') {
            return true
        }
        
        sleep(5)
    }
    
    error "Health check failed after ${maxRetries} retries"
}
```

### Performance Metrics

```groovy
stage('Performance Tests') {
    steps {
        sh 'make perf-test'
        
        perfReport(
            filterRegex: '',
            performanceFailedThreshold: 10,
            performanceUnstableThreshold: 5,
            relativeFailedThresholdNegative: 0.0,
            relativeUnstableThresholdNegative: 0.0,
            modePerformancePerBuildReport: true,
            modeThroughput: false,
            reportFiles: 'perf-results.xml'
        )
    }
}
```

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Build too slow | Use caching, parallel stages, incremental builds |
| Flaky tests | Retry mechanism, test isolation, proper cleanup |
| Secret exposure | Use Jenkins credentials, mask variables |
| Deployment failures | Blue-green, canary releases, automatic rollbacks |
| Missing logs | Structured logging, centralized log aggregation |

## Best Practices Checklist

- [ ] Use declarative pipeline syntax
- [ ] Keep pipelines as code (in repository)
- [ ] Implement proper error handling
- [ ] Use credentials for secrets
- [ ] Add health checks
- [ ] Implement rollback strategy
- [ ] Use parallel stages for speed
- [ ] Add proper notifications
- [ ] Keep sensitive data out of logs
- [ ] Use version pinning for dependencies

## References

- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [Jenkins Security](https://www.jenkins.io/doc/book/security/)
- [Docker Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
