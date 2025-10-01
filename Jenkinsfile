pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = 'nkdesilva/sonar-react-app'
        SONARQUBE = 'SonarQubeServer'
        AWS_REGION = "ap-southeast-2"
        ECR_REPO = "public.ecr.aws/t3s0h7f3/nkdsilva/docker-app"
        DOCKER_IMAGE = "${ECR_REPO}:${BUILD_NUMBER}"
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
                waitForQualityGate abortPipeline: true
            }
        }

        stage('Docker Build & Push to ECR') {
            steps {
                withAWS(region: "${AWS_REGION}", credentials: 'aws-credentials') {
                    script {
                        sh '''
                        aws ecr-public get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin public.ecr.aws
                        docker build -t ${DOCKER_IMAGE} .
                        docker push ${DOCKER_IMAGE}
                        '''
                    }
                }
            }
        }

        stage('Deploy to Apache Server') {
            steps {
                sshagent(['apache-server-key']) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no ubuntu@15.134.33.63 "
                        docker pull ${DOCKER_IMAGE} &&
                        docker stop react-container || true &&
                        docker rm react-container || true &&
                        docker run -d --name react-container -p 80:80 ${DOCKER_IMAGE}
                    "
                    '''
                }
            }
        }
        
        // stage('Docker Build & Push') {
        //     steps {
        //         sh 'docker build -t $DOCKER_HUB_REPO .'
        //         withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
        //             sh 'echo $PASSWORD | docker login -u $USERNAME --password-stdin'
        //             sh 'docker push $DOCKER_HUB_REPO'
        //         }
        //     }
        // }

        // stage('Deploy to Apache Server') {
        //     steps {
        //         sshagent(['apache-server-key']) {
        //             sh '''
        //             ssh ubuntu@15.134.33.63 "docker pull $DOCKER_HUB_REPO && docker stop react-app || true && docker rm react-app || true && docker run -d --name react-app -p 80:80 $DOCKER_HUB_REPO"
        //             '''
        //         }
        //     }
        // }
    }
}