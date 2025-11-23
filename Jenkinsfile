pipeline {
    agent any
    
    environment {
        DOCKER_NETWORK = 'final-project'
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
                    // Build your Docker image
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
                        ml-app
                    '''
                }
            }
        }
        
      stage('Health Check') {
    steps {
        script {
            sh 'sleep 5'
            sh 'docker ps | grep ${APP_CONTAINER}'
                 }
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}