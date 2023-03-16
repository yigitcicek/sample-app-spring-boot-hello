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
    environment {
        IMAGE_NAME = "yigitcicek/spring-demo:sample-1.0"
    }
    stages {
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
                    def dockerCommand = "docker run -d -p 80:80 ${IMAGE_NAME}"
                    echo "ip is ${IP}"
                    sshagent(['ec2-sample-app-001-key']) {
                        sh "ssh -o StrictHostKeyChecking=no ubuntu@${IP} ${dockerCommand}"
                    }
                }
            }
        }
    }
}
