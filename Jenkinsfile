pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = '056c86ab-fddc-40cb-a7c4-ac291c8b9143'
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
                    ls -la
                    node --version
                    npm --version
                    npm ci
                    npm run build
                    ls -la
                '''
            }
        }
        
        stage('Tests'){
            parallel {
                stage('Unit tests') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            npm test
                        '''
                    }
                    //post action
                    post {
                        //it will be executed everytime
                        always { 
                            //path to the junit.xml file where the results will be recorded
                            junit 'jest-results/junit.xml'
                        }
                    }
                }
                stage('E2E') {
                    agent {
                        docker {
                            image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            npm install serve #uses serve locally
                            node_modules/.bin/serve -s build & #start server in the background
                            sleep 10
                            npx playwright test --reporter=html
                        '''
                    }
                    //post action
                    post {
                        //it will be executed everytime
                        always { 
                            //html report
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright HTML Report', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                }
            }
        }

        stage('Deploy') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    npm i netlify-cli
                    netlify --version
                '''
            }
        }
    }
}