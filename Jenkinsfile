pipeline {
    agent any

    environment {
        REACT_APP_VERSION = "1.0.$BUILD_ID"
        AWS_DEFAULT_REGION = 'us-east-1'
        AWS_ECS_CLUSTER = 'UdemyLearnJenkinsApp-Cluster-Prod'
        AWS_ECS_SERVICE_PROD = 'UdemyLearnJenkinsApp-Service-Prod'
        AWS_ECS_TD_PROD = 'UdemyLearnJenkinsApp-TaskDefinition-Prod'
    }

    stages {
        
        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    //use same agent for all the steps and share workspace
                    reuseNode true
                }
            }
            steps {
                sh '''
                    echo 'Small change'
                    ls -la
                    node --version
                    npm --version
                    npm ci
                    npm run build
                    ls -la
                '''
            }
        }

        /*We're creating a link between our host from where we're running this container and the inside of our container
        -v <host_path>:<container_path>
        */
        stage('Build Docker image') {
            agent {
                docker {
                    image 'my-aws-cli'
                    reuseNode true
                    args '-u root -v /var/run/docker.sock:/var/run/docker.sock --entrypoint=""'
                }
            }

            steps {
                sh '''
                    docker build -t myjenkinsapp .
                '''
            }
        }

        stage('Deploy to AWS') {
            agent {
                docker {
                    image 'my-aws-cli'
                    reuseNode true
                    args '-u root --entrypoint=""'
                }
            }

            steps {
                withCredentials([usernamePassword(credentialsId: 'my-aws', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                        aws --version
                        LATEST_TD_REVISION=$(aws ecs register-task-definition --cli-input-json file://aws/task-definition-prod.json  | jq '.taskDefinition.revision')
                        aws ecs update-service --cluster $AWS_ECS_CLUSTER --service $AWS_ECS_SERVICE_PROD --task-definition $AWS_ECS_TD_PROD:$LATEST_TD_REVISION
                        aws ecs wait services-stable --cluster $AWS_ECS_CLUSTER --services $AWS_ECS_SERVICE_PROD
                    '''
                }

            }
        }
    }
}
