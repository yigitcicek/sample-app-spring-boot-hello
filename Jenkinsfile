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
                    env.IMAGE_NAME = "$version-$BUILD_NUMBER"
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
                    buildImage("sample-app-spring-boot-hello:${env.IMAGE_NAME}")
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
                        sh "scp docker-compose.yaml ubuntu@${IP}:/home/ubuntu/app"
                        sh "scp commands.sh ubuntu@${IP}:/home/ubuntu/app"
                        sh "ssh -o StrictHostKeyChecking=no ubuntu@${IP} cd app && ${shellCommand}"
                    }
                }
            }
        }

        stage("commit version update") {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'github-y-credentials', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                        sh 'git config --global user.email "jenkins@example.com"'
                        sh 'git config --global user.name "jenkins"'

                        sh "git remote set-url origin https://${USERNAME}:${PASSWORD}@github.com/yigitcicek/sample-app-spring-boot-hello/"
                        sh "git add ."
                        sh 'git commit -m "ci: version bump"'
                        sh "git push origin HEAD:docekr-compose-ci-cd"
                    }
                }
            }
        }
    }
}
