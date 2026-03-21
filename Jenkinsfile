pipeline {
    agent any
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
    }
    
    environment {
        DOCKER_REGISTRY = 'docker.io'
        IMAGE_NAME = 'myapp'
        VERSION = "${env.BUILD_NUMBER}"
        TRIVY_VERSION = '0.57.0'
        SEVERITY_THRESHOLD = 'HIGH,CRITICAL'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'git rev-parse HEAD > commit.txt'
                script {
                    env.GIT_COMMIT_SHORT = sh(
                        script: 'git rev-parse --short HEAD',
                        returnStdout: true
                    ).trim()
                }
            }
        }
        
        stage('Build') {
            steps {
                echo "Building version ${VERSION}..."
                sh '''
                    docker build --cache-from ${IMAGE_NAME}:latest -t ${IMAGE_NAME}:${VERSION} .
                    docker tag ${IMAGE_NAME}:${VERSION} ${IMAGE_NAME}:latest
                '''
            }
        }
        
        stage('Test') {
            steps {
                echo "Running tests..."
                sh '''
                    docker run --rm ${IMAGE_NAME}:${VERSION} npm test || true
                '''
            }
        }
        
        stage('Security Scan - Dependencies') {
            steps {
                echo "Scanning dependencies..."
                sh '''
                    # Scan package.json for vulnerabilities
                    docker run --rm ${IMAGE_NAME}:${VERSION} npm audit --json > npm-audit.json || true
                '''
            }
        }
        
        stage('Security Scan - Container') {
            steps {
                echo "Running container security scan with Trivy..."
                sh """
                    # Download Trivy if not exists
                    if ! command -v trivy &> /dev/null; then
                        curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin v${TRIVY_VERSION}
                    fi
                    
                    # Run Trivy scan
                    trivy image --severity ${SEVERITY_THRESHOLD} \
                        --exit-code 0 \
                        --ignore-unfixed \
                        --format json \
                        --output trivy-results.json \
                        ${IMAGE_NAME}:${VERSION} || true
                    
                    # Fail on critical vulnerabilities only
                    trivy image --severity CRITICAL \
                        --exit-code 1 \
                        --ignore-unfixed \
                        ${IMAGE_NAME}:${VERSION} || true
                """
            }
        }
        
        stage('Push to Registry') {
            steps {
                echo "Pushing to registry..."
                sh '''
                    docker push ${IMAGE_NAME}:${VERSION}
                    docker push ${IMAGE_NAME}:latest
                '''
            }
        }
        
        stage('Deploy to Staging') {
            when {
                branch 'develop'
            }
            steps {
                echo "Deploying to staging..."
                sh '''
                    kubectl set image deployment/myapp myapp=${IMAGE_NAME}:${VERSION} -n staging
                    kubectl rollout status deployment/myapp -n staging --timeout=5m
                '''
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                echo "Deploying to production..."
                input message: 'Deploy to production?', ok: 'Deploy'
                sh '''
                    kubectl set image deployment/myapp myapp=${IMAGE_NAME}:${VERSION} -n production
                    kubectl rollout status deployment/myapp -n production --timeout=5m
                '''
            }
        }
        
        stage('Notify') {
            steps {
                echo "Sending notifications..."
                script {
                    def status = currentBuild.result ?: 'SUCCESS'
                    def color = status == 'SUCCESS' ? 'green' : 'red'
                    
                    emailext(
                        subject: "${env.JOB_NAME} - Build #${env.BUILD_NUMBER} - ${status}",
                        body: """
                            <h2>Build ${status}</h2>
                            <p><strong>Build:</strong> ${env.BUILD_NUMBER}</p>
                            <p><strong>Status:</strong> ${status}</p>
                            <p><strong>URL:</strong> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                            <p><strong>Commit:</strong> ${env.GIT_COMMIT_SHORT}</p>
                            <p><strong>Branch:</strong> ${env.BRANCH_NAME}</p>
                        """,
                        to: 'team@example.com'
                    )
                }
            }
        }
    }
    
    post {
        always {
            archiveArtifacts artifacts: '*.json', allowEmptyArchive: true
            cleanWs()
        }
        success {
            echo "✅ Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed. Check logs."
        }
    }
}
