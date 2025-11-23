pipeline {
    agent any
    
    environment {
        DOCKER_NETWORK = 'final-project_final-project'
        APP_CONTAINER = 'final-project-ml-app'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/hemalmewan/Final-Project.git'
            }
        }
        
        stage('Build') {
            steps {
                script {
                    sh 'docker build -t ml-product-app:latest .'
                }
            }
        }
        
        stage('Deploy') {
            steps {
                script {
                    // Stop old container
                    sh 'docker stop ${APP_CONTAINER} || true'
                    sh 'docker rm ${APP_CONTAINER} || true'
                    
                    // Run new container on the same network
                    sh '''
                        docker run -d \
                        --name ${APP_CONTAINER} \
                        --network ${DOCKER_NETWORK} \
                        -p 8000:8000 \
                        ml-product-app:latest
                    '''
                }
            }
        }
        
        stage('Health Check') {
            steps {
                script {
                    // Wait for container to start
                    sh 'sleep 5'
                    
                    // Check if container is running
                    sh '''
                        if docker ps --format "{{.Names}}" | grep -q "^${APP_CONTAINER}$"; then
                            echo "Container ${APP_CONTAINER} is running"
                            docker logs ${APP_CONTAINER} --tail 20
                        else
                            echo "Container ${APP_CONTAINER} is not running!"
                            docker logs ${APP_CONTAINER} --tail 50
                            exit 1
                        fi
                    '''
                }
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline succeeded! Application deployed successfully.'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}