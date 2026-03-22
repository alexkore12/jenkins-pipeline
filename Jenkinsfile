pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'docker.io'
        IMAGE_NAME = 'myapp'
        VERSION = "${env.BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'git rev-parse HEAD > commit.txt'
            }
        }
        
        stage('Build') {
            steps {
                echo "Building version ${VERSION}..."
                sh '''
                    docker build -t ${IMAGE_NAME}:${VERSION} .
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
        
        stage('Security Scan') {
            steps {
                echo "Running security scans..."
                sh '''
                    # Trivy vulnerability scan
                    docker run --rm \
                        -v /var/run/docker.sock:/var/run/docker.sock \
                        aquasec/trivy image --severity HIGH,CRITICAL ${IMAGE_NAME}:${VERSION} || true
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
        
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                echo "Deploying to production..."
                input message: 'Deploy to production?', ok: 'Deploy'
                sh '''
                    kubectl set image deployment/myapp myapp=${IMAGE_NAME}:${VERSION} -n production
                '''
            }
        }
        
        stage('Notify') {
            steps {
                echo "Sending notifications..."
                emailext(
                    subject: "${env.JOB_NAME} - Build #${env.BUILD_NUMBER} - ${currentBuild.result}",
                    body: """
                        Build: ${env.BUILD_NUMBER}
                        Status: ${currentBuild.result}
                        URL: ${env.BUILD_URL}
                        Commit: ${readFile('commit.txt')}
                    """,
                    to: 'team@example.com'
                )
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed. Check logs."
        }
    }
}
