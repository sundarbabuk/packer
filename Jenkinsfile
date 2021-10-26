pipeline {
    agent any
    environment {
        AWS_DEFAULT_REGION="us-east-1"
        AWS_ACCESS_KEY_ID     = credentials('jenkins-aws-secret-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('jenkins-aws-secret-access-key')
    }

        
    options {
        ansiColor('xterm')
    }


    stages {
      
        stage("Packer Initialize") {
            steps {
                sh "/var/jenkins_home/packer init ."
            }
        }

        stage("Packer Format") {
            steps {
                sh "/var/jenkins_home/packer fmt ."
            }
        }

        stage("Packer Validate") {
            steps {
                sh "/var/jenkins_home/packer validate ."
            }
        }

        stage("Build Hardened AMI Image") {
            steps {
                sh "/var/jenkins_home/packer build hardened-ami-image.pkr.hcl"
                
                }            
            }
        }
    }

               
      


