pipeline {
    agent any
    
    environment {
        DOCKER_NETWORK = 'final-project_final-project'
        APP_CONTAINER = 'final-project-ml-app'
        DOCKERHUB_REPO = 'hemalmewan/ml-app'
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        GIT_COMMIT_SHORT = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/hemalmewan/Final-Project.git'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                        docker build -t ${DOCKERHUB_REPO}:latest \
                                     -t ${DOCKERHUB_REPO}:${IMAGE_TAG} \
                                     -t ${DOCKERHUB_REPO}:${GIT_COMMIT_SHORT} \
                                     .
                    """
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    sh """
                        echo \$DOCKERHUB_CREDENTIALS_PSW | docker login -u \$DOCKERHUB_CREDENTIALS_USR --password-stdin
                        docker push ${DOCKERHUB_REPO}:latest
                        docker push ${DOCKERHUB_REPO}:${IMAGE_TAG}
                        docker push ${DOCKERHUB_REPO}:${GIT_COMMIT_SHORT}
                        docker logout
                    """
                    
                    echo "Images pushed successfully:"
                    echo "  - ${DOCKERHUB_REPO}:latest"
                    echo "  - ${DOCKERHUB_REPO}:${IMAGE_TAG}"
                    echo "  - ${DOCKERHUB_REPO}:${GIT_COMMIT_SHORT}"
                }
            }
        }
        
        stage('Deploy') {
            steps {
                script {
                    sh 'docker stop ${APP_CONTAINER} || true'
                    sh 'docker rm ${APP_CONTAINER} || true'
                    
                    sh """
                        docker run -d \
                        --name ${APP_CONTAINER} \
                        --network ${DOCKER_NETWORK} \
                        -p 8000:8000 \
                        ${DOCKERHUB_REPO}:${IMAGE_TAG}
                    """
                }
            }
        }
        
        stage('Health Check') {
            steps {
                script {
                    sh 'sleep 10'
                    
                    sh """
                        if docker ps --format "{{.Names}}" | grep -q "^${APP_CONTAINER}\$"; then
                            echo "✓ Container ${APP_CONTAINER} is running"
                            echo "✓ Version: ${IMAGE_TAG}"
                            echo "✓ Git Commit: ${GIT_COMMIT_SHORT}"
                            docker logs ${APP_CONTAINER} --tail 20
                        else
                            echo "✗ Container ${APP_CONTAINER} is not running!"
                            docker logs ${APP_CONTAINER} --tail 50
                            exit 1
                        fi
                    """
                }
            }
        }
    }
    
    post {
        success {
            echo """
            ========================================
            🎉 Deployment Successful!
            ========================================
            Version: ${IMAGE_TAG}
            Git Commit: ${GIT_COMMIT_SHORT}
            Docker Hub: https://hub.docker.com/r/${DOCKERHUB_REPO}
            Application: http://localhost:8000
            ========================================
            """
        }
        failure {
            echo 'Pipeline failed! Check logs above.'
        }
        always {
            sh 'docker image prune -f || true'
        }
    }
}