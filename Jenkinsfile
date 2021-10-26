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
      
        stage("Build Hardened AMI Image") {
            steps {
                sh """
                #!/bin/bash
                cd config
                /var/jenkins_home/packer init .
                /var/jenkins_home/packer build aws-cis-hardened-image.pkr.hcl
                """
                }            
            }
        }
    }

               
      


