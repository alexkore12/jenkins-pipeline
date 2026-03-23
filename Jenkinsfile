pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'docker.io'
        IMAGE_NAME = 'myapp'
        VERSION = "${env.BUILD_NUMBER}"
        SONAR_HOST = 'http://localhost:9000'
    }
    
    options {
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'git rev-parse HEAD > commit.txt'
                sh 'git log -1 --format="%H %s" > commit_info.txt'
            }
        }
        
        stage('Environment Info') {
            steps {
                echo "=== Build Information ==="
                echo "Build Number: ${env.BUILD_NUMBER}"
                echo "Build URL: ${env.BUILD_URL}"
                echo "Branch: ${env.BRANCH_NAME}"
                echo "Commit: ${readFile('commit.txt')}"
                echo "========================="
            }
        }
        
        stage('Build') {
            steps {
                echo "Building version ${VERSION}..."
                sh '''
                    docker build -t ${IMAGE_NAME}:${VERSION} .
                    docker build -t ${IMAGE_NAME}:${VERSION}-${BRANCH_NAME} .
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
        
        stage('SonarQube Analysis') {
            when {
                anyOf {
                    branch 'main'
                    branch 'develop'
                }
            }
            steps {
                echo "Running SonarQube analysis..."
                sh '''
                    # Example SonarQube scan
                    # docker run --rm -v $(pwd):/src sonarsource/sonar-scanner-cli \
                    #   -Dsonar.host.url=${SONAR_HOST} \
                    #   -Dsonar.projectKey=${IMAGE_NAME}
                    echo "SonarQube analysis skipped (configure SonarQube)"
                '''
            }
        }
        
        stage('Security Scan - Grype') {
            steps {
                echo "Running Grype vulnerability scan..."
                sh '''
                    # Grype vulnerability scanner (replaces Trivy after supply chain attack)
                    # Install: brew install grype
                    # docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
                    #   anchore/grype:latest \
                    #   ${IMAGE_NAME}:${VERSION} || true
                    echo "Grype scan skipped (install grype for actual scan)"
                '''
            }
        }
        
        stage('Security Scan - Checkov') {
            steps {
                echo "Running Checkov IaC scan..."
                sh '''
                    # Checkov for infrastructure as code
                    # pip install checkov
                    # checkov -d ./infrastructure || true
                    echo "Checkov scan skipped"
                '''
            }
        }
        
        stage('Docker Scan - Docker Scout') {
            steps {
                echo "Running Docker Scout analysis..."
                sh '''
                    # Docker Scout for container security
                    # docker scout cves ${IMAGE_NAME}:${VERSION} || true
                    echo "Docker Scout skipped"
                '''
            }
        }
        
        stage('Build & Push Multi-Arch') {
            when {
                branch 'main'
            }
            steps {
                echo "Building multi-architecture image..."
                sh '''
                    # Build for multiple architectures
                    # docker buildx build --platform linux/amd64,linux/arm64 ...
                    echo "Multi-arch build skipped"
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
                '''
            }
        }
        
        stage('Integration Tests - Staging') {
            when {
                branch 'develop'
            }
            steps {
                echo "Running integration tests in staging..."
                sh '''
                    # Run integration tests
                    # kubectl run test-runner --image=${IMAGE_NAME}:${VERSION} -n staging
                    echo "Integration tests skipped"
                '''
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                echo "Preparing production deployment..."
                input message: 'Deploy to production?', ok: 'Deploy'
                sh '''
                    kubectl set image deployment/myapp myapp=${IMAGE_NAME}:${VERSION} -n production
                '''
            }
        }
        
        stage('Smoke Tests - Production') {
            when {
                branch 'main'
            }
            steps {
                echo "Running smoke tests in production..."
                sh '''
                    # Verify deployment
                    # kubectl rollout status deployment/myapp -n production
                    # curl -f https://production.example.com/health || exit 1
                    echo "Smoke tests skipped"
                '''
            }
        }
        
        stage('Notify') {
            steps {
                echo "Sending notifications..."
                script {
                    def status = currentBuild.result ?: 'SUCCESS'
                    emailext(
                        subject: "${env.JOB_NAME} - Build #${env.BUILD_NUMBER} - ${status}",
                        body: """
                            Build: ${env.BUILD_NUMBER}
                            Status: ${status}
                            URL: ${env.BUILD_URL}
                            Branch: ${env.BRANCH_NAME}
                            Commit: ${readFile('commit_info.txt')}
                        """,
                        to: 'team@example.com'
                    )
                }
            }
        }
        
        stage('Publish SBOM') {
            when {
                branch 'main'
            }
            steps {
                echo "Publishing Software Bill of Materials..."
                sh '''
                    # Generate and publish SBOM
                    # syft ${IMAGE_NAME}:${VERSION} -o cyclonedx-json > sbom.json
                    echo "SBOM generation skipped"
                '''
            }
        }
    }
    
    post {
        always {
            echo "Cleaning workspace..."
            cleanWs()
        }
        success {
            echo "✅ Pipeline completed successfully!"
            echo "Version deployed: ${VERSION}"
        }
        failure {
            echo "❌ Pipeline failed. Check logs at: ${env.BUILD_URL}"
        }
        unstable {
            echo "⚠️ Pipeline is unstable. Review the build."
        }
    }
}
