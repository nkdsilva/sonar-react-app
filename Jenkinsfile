pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = 'nkdesilva/sonar-react-app'
        SONARQUBE = 'SonarQubeServer'
	
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'dev', url: 'https://github.com/nkdsilva/sonar-react-app.git'
            }
        }

        stage('Install & Test') {
            steps {
                sh 'npm install'
                sh 'npm test -- --coverage'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQubeServer') {
                    sh 'npx sonar-scanner'
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                sh 'docker build -t $DOCKER_HUB_REPO .'
                withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh 'echo $PASSWORD | docker login -u $USERNAME --password-stdin'
                    sh 'docker push $DOCKER_HUB_REPO'
                }
            }
        }

        stage('Deploy to Apache Server') {
            steps {
                sshagent(['apache-server-key']) {
                    sh '''
                    ssh ubuntu@15.134.33.63 "docker pull $DOCKER_HUB_REPO && docker stop react-app || true && docker rm react-app || true && docker run -d --name react-app -p 80:80 $DOCKER_HUB_REPO"
                    '''
                }
            }
        }
    }
}