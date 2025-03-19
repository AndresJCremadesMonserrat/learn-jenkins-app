pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = '056c86ab-fddc-40cb-a7c4-ac291c8b9143'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
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
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright Local', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                }
                stage('Prod E2E') {
                    agent {
                        docker {
                            image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                            reuseNode true
                        }
                    }

                    environment {
                        CI_ENVIRONMENT_URL = 'https://ubiquitous-stroopwafel-a329f0.netlify.app'
                    }

                    steps {
                        sh '''
                            npx playwright test --reporter=html
                        '''
                    }
                    //post action
                    post {
                        //it will be executed everytime
                        always { 
                            //html report
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright E2E', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                }
            }
        }

        stage('Deploy staging') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    npm i netlify-cli
                    node_modules/.bin/netlify --version
                    echo "DEploying to production. Site ID: $NETLIFY_SITE_ID"
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy --dir=build
                '''
            }
        }

        stage('Approval') {
            steps {
                timeout(time: 1, unit: 'MINUTES'){
                    input message: 'Ready to deploy?', ok: 'Yes, I am sure I want to deploy!'
                }
            }
        }

        stage('Deploy prod') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    npm i netlify-cli
                    node_modules/.bin/netlify --version
                    echo "DEploying to production. Site ID: $NETLIFY_SITE_ID"
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy --dir=build --prod
                '''
            }
        }
    }
}