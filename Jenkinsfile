pipeline {
    agent any
    
    environment {
        DOCKER_NETWORK = 'final-project_final-project'
        APP_CONTAINER = 'final-project-ml-app'
        DOCKERHUB_REPO = 'hemalmewan/ml-app'  // Change this to your Docker Hub repo
        DOCKERHUB_CREDENTIALS = 'dockerhub-credentials'
        IMAGE_TAG = "${env.BUILD_NUMBER}"  // Use Jenkins build number as version
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
                    // Build with multiple tags: latest, build number, and git commit
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
                    // Login to Docker Hub and push all tags
                    docker.withRegistry('https://registry.hub.docker.com', DOCKERHUB_CREDENTIALS) {
                        sh """
                            docker push ${DOCKERHUB_REPO}:latest
                            docker push ${DOCKERHUB_REPO}:${IMAGE_TAG}
                            docker push ${DOCKERHUB_REPO}:${GIT_COMMIT_SHORT}
                        """
                    }
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
                    // Stop and remove old container
                    sh 'docker stop ${APP_CONTAINER} || true'
                    sh 'docker rm ${APP_CONTAINER} || true'
                    
                    // Deploy new version from Docker Hub
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
                    
                    // Check if container is running
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
             Deployment Successful!
            ========================================
            Version: ${IMAGE_TAG}
            Git Commit: ${GIT_COMMIT_SHORT}
            Docker Hub: ${DOCKERHUB_REPO}
            Application: http://localhost:8000
            ========================================
            """
        }
        failure {
            echo 'Pipeline failed! Check logs above.'
        }
        always {
            // Clean up old images to save space (optional)
            sh 'docker image prune -f || true'
        }
    }
}