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
        IMAGE_NAME = "nginx"
    }
    stages {
        stage("test") {
            steps {
                script {
                    echo "testing ..........."
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
                }
            }
        }
        stage("deploy") {
            input {
                message "Ec2 instance private"
                ok "Done"
                parameters {
                    string defaultValue: "", description: "target ec2 private IP address", name: "IP", trim: true
                }
            }
            steps {
                script {
                    echo "deploying ..........."
                    def dockerCommand = "docker run -d -p 80:80 nginx"
                    echo "ip is ${IP}"
                    sshagent(['ec2-sample-app-001-key']) {
                        sh "ssh -o StrictHostKeyChecking=no ubuntu@${IP} ${dockerCommand}"
                    }
                }
            }
        }
    }
}
