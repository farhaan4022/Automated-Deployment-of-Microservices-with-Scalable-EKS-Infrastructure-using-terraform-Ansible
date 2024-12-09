pipeline {
    agent any

    environment {
        TF_VAR_FILE = 'terraform.tfvars' // Variables file
    }

    stages {
        stage('Terraform Init') {
            steps {
                echo 'Initializing Terraform...'
                sh 'terraform init'
            }
        }
        stage('Terraform Plan') {
            steps {
                echo 'Planning Terraform changes...'
                sh 'terraform plan -var-file=${TF_VAR_FILE}'
            }
        }
        stage('Terraform Apply') {
            steps {
                echo 'Applying Terraform configuration...'
                sh 'terraform apply -auto-approve -var-file=${TF_VAR_FILE}'
            }
        }
    }

    post {
        success {
            echo 'Terraform workflow completed successfully!'
        }
        failure {
            echo 'Terraform workflow failed. Check logs for details.'
        }
    }
}
