#!/usr/bin/env groovy

library identifier: "sample-jenkins-shared-library@main", retriever modernSCM(
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
        // stage("deploy") {
        //     steps {
        //         script {
        //             echo "deploying ..........."
        //             def dockerCommand = "docker run -d -p 80:80 nginx"
        //             sshagent(['sample-app-v1-key']) {
        //                 sh "ssh -o StrictHostKeyChecking=no ubuntu@172.31.42.36 ${dockerCommand}"
        //             }
        //         }
        //     }
        // }
    }
}
