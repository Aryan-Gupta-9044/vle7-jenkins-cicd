pipeline {
    agent any

    environment {
        IMAGE_NAME = "vle7-demo"
        KUBECONFIG = "/var/jenkins_home/.kube/config"
        DOCKERHUB = credentials('dockerhub-creds')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Test') {
            steps {
                sh '''
                    grep -q "VLE 7" app/index.html
                    grep -q "Jenkins CI/CD" app/index.html
                    echo "Application tests passed"
                '''
            }
        }

        stage('Build') {
            steps {
                sh '''
                    docker build -t $DOCKERHUB_USR/$IMAGE_NAME:$BUILD_NUMBER .
                    docker tag $DOCKERHUB_USR/$IMAGE_NAME:$BUILD_NUMBER $DOCKERHUB_USR/$IMAGE_NAME:latest
                '''
            }
        }

        stage('Push') {
            steps {
                sh '''
                    echo "$DOCKERHUB_PSW" | docker login -u "$DOCKERHUB_USR" --password-stdin
                    docker push $DOCKERHUB_USR/$IMAGE_NAME:$BUILD_NUMBER
                    docker push $DOCKERHUB_USR/$IMAGE_NAME:latest
                    docker logout
                '''
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml

                    kubectl set image deployment/vle7-web \
                      vle7-web=$DOCKERHUB_USR/$IMAGE_NAME:$BUILD_NUMBER

                    kubectl rollout status deployment/vle7-web --timeout=120s
                '''
            }
        }

        stage('Verify') {
            steps {
                sh '''
                    kubectl get deployments
                    kubectl get pods -l app=vle7-web
                    kubectl get service vle7-service
                '''
            }
        }
    }

    post {
        success {
            echo 'VLE 7 CI/CD pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check the stage logs.'
        }
    }
}
