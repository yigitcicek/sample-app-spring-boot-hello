#!/usr/bin/env groovy

library identifier: "sample-jenkins-shared-library@main", retriever: modernSCM(
    [$class: "GitSCMSource",
     remote: "https://github.com/yigitcicek/sample-jenkins-shared-library.git",
     credentialsId: "github-y-credentials"
    ]
)

pipeline {
    agent any
    tools {
        maven "maven-3.9"
    }
    stages {
        stage("increment version") {
            steps {
                script {
                    echo "incrementing app version..."
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

        stage("deploy") {
            input {
                // get ec2 instance private IP
                message "Ec2 instance private"
                ok "Done"
                parameters {
                    string defaultValue: "", description: "target ec2 private IP address", name: "IP", trim: true
                }
            }
            steps {
                script {
                    echo "deploying ..........."
                    def shellCommand = "bash ./commands.sh ${IMAGE_NAME}"
                    sshagent(['ec2-sample-app-001-key']) {
                        sh "scp docker-compose.yaml ubuntu@${IP}:/home/ubuntu/"
                        sh "scp commands.sh ubuntu@${IP}:/home/ubuntu/"
                        sh "ssh -o StrictHostKeyChecking=no ubuntu@${IP} ${shellCommand}"
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
                        git commit -m "Jenkins build ${BUILD_NUMBER}"
                        git push origin HEAD:feature/docker-compose-ci-cd
                        '''
                    }
                }
            }
        }
    }
}
