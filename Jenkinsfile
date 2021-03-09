pipeline {
    agent { label "docker" }
    options {
        // Do not omit this option, otherwise it will start eating all the disk space and we will be forced to delete
        // the job to avoid a Jenkins DoS
        buildDiscarder(logRotator(numToKeepStr:"10"))
        // helpful when looking at docker or node output which tends to send ansi sequences even without a tty.
        ansiColor("xterm")
        timeout(time: 30, unit: "MINUTES")
    }
    stages {
        stage('Build') {
            steps {
                withCredentials([[$class: "AmazonWebServicesCredentialsBinding", accessKeyVariable: "AWS_ACCESS_KEY_ID", credentialsId: "aws cred", secretKeyVariable: "AWS_SECRET_ACCESS_KEY"]]) {
                    sh 'make build'
                }
            }
        }
        stage('Push') {
            steps {
                sh 'make docker-push'
            }
        }
    }
}