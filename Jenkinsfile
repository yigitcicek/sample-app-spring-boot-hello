#!/usr/bin/env groovy

library identifier: "sample-jenkins-shared-library@main", retriever: modernSCM(
    [$class: "GitSCMSource",
     remote: "https://github.com/yigitcicek/sample-jenkins-shared-library.git",
     credentialsId: "github-y-credentials"
    ]
)

environment {
    IP_TO_ALLOW_SSH = ""
    JENKINS_IP_TO_ALLOW_SSH = ""
}

pipeline {
    agent any
    tools {
        maven "maven-3.9"
    }
    stages {
        stage ("user_input"){
            input {
                // give your IP to allow access to ssh to ec2
                message "Your IP address"
                ok "Done"
                parameters { [
                    string( defaultValue: "", description: "your ip address", name: "OWN_IP", trim: true),
                    string (defaultValue: "", description: "jenkins ip address", name: "JENKINS_IP", trim: true)
                    ]
                }
            }
            
            steps{
                script {
                    echo "getting user input ..........."
                    sh "printenv"
                    // INPUT_PARAMS = input message: "enter own ip to allow ssh for new ec2", parameters [
                    //     string(description: 'Own IP', defaultValue: '', name: 'own_ip'),
                    // ]
                    IP_TO_ALLOW_SSH = "${OWN_IP}"
                    JENKINS_IP_TO_ALLOW_SSH = "${JENKINS_IP}"
                }
            }
        }

        stage("increment version") {
            steps {
                script {
                    echo "incrementing app version ..........."
                    sh "mvn build-helper:parse-version versions:set \
                        -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} \
                        versions:commit"
                    def matcher = readFile('pom.xml') =~ "<version>(.+)</version>"
                    def version = matcher[0][1]
                    env.IMAGE_NAME = "yigitcicek/sample-app-spring-boot-hello:$version-$BUILD_NUMBER"
                    echo "$IMAGE_NAME"
                }
            }
        }

        stage("build app") {
            steps {
                script {
                    echo "building ..........."
                    buildJar()
                }
            }
        }

        stage("build image") {
            steps {
                script {
                    echo "building image ..........."
                    buildImage(env.IMAGE_NAME)
                }
            }
        }

        stage("push image") {
            steps {
                script {
                    echo "pushing image ..........."
                    dockerLogin()
                    dockerPush(env.IMAGE_NAME)
                }
            }
        }

        stage("provision server") {
            // input {
            //     // give your IP to allow access to ssh to ec2
            //     message "Your IP address"
            //     ok "Done"
            //     parameters {
            //         string defaultValue: "", description: "your ip address", name: "OWN_IP", trim: true
            //     }
            // }
            environment {
                AWS_ACCESS_KEY_ID = credentials("jenkins_aws_access_key_id")
                AWS_SECRET_ACCESS_KEY = credentials("jenkins_aws_secret_access_key")
                TF_VAR_env_prefix = "test"
                TF_VAR_my_ip = "${IP_TO_ALLOW_SSH}"
            }
            steps {
                script {
                    dir("terraform") {
                        echo "own ip is set to ${IP_TO_ALLOW_SSH}"
                        sh "terraform init"
                        sh "terraform apply --auto-approve"
                        EC2_IP_TO_DEPLOY = sh(
                            script: "terraform output ec2_public_ip",
                            returnStdout: true
                        ).trim()
                    }
                }
            }
        }

        stage("deploy") {
            // input {
            //     // get ec2 instance private IP
            //     message "Ec2 instance private"
            //     ok "Done"
            //     parameters {
            //         string defaultValue: "", description: "target ec2 private IP address", name: "IP", trim: true
            //     }
            // }
            steps {
                script {
                    echo "deploying ..........."

                    sleep(time: 90, unit: "SECONDS")

                    echo "ec2 ip is ${EC2_IP_TO_DEPLOY}"

                    def shellCommand = "bash ./commands.sh ${IMAGE_NAME}"
                    sshagent(['ec2-sample-app-001-key']) {
                        sh "scp -o StrictHostKeyChecking=no docker-compose.yaml ubuntu@${EC2_IP_TO_DEPLOY}:/home/ubuntu/"
                        sh "scp -o StrictHostKeyChecking=no commands.sh ubuntu@${EC2_IP_TO_DEPLOY}:/home/ubuntu/"
                        sh "ssh -o StrictHostKeyChecking=no ubuntu@${EC2_IP_TO_DEPLOY} ${shellCommand}"
                    }
                }
            }
        }

        stage('push version bump to github') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'common-jenkins-token-v1', variable: 'TOKEN')]) {
                        sh '''
                        git config --global user.email "jenkins@example.com"
                        git config --global user.name "Jenkins"
                        git remote remove origin
                        git remote add origin https://yigitcicek:$TOKEN@github.com/yigitcicek/sample-app-spring-boot-hello.git
                        git remote set-url origin https://yigitcicek:$TOKEN@github.com/yigitcicek/sample-app-spring-boot-hello.git
                        git add .
                        git commit -m "version bump from jenkins build number: ${BUILD_NUMBER}"
                        git push origin HEAD:feature/docker-compose-ci-cd
                        '''
                    }
                }
            }
        }
    }
}
