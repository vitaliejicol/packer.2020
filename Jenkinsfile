def aws_region_var = ''
def environment = ''


if(env.BRANCH_NAME ==~ "dev.*"){
    aws_region_var = "us-east-1"
    environment = "dev"
}
else if(env.BRANCH_NAME ==~ "qa.*"){
    aws_region_var = "us-east-2"
    environment = "qa"
}
else if(env.BRANCH_NAME ==~ "master"){
    aws_region_var = "us-west-2"
    environment = "prod"
}
def tf_vars = """
    s3_bucket = "terraform-vpc.groovy"
    s3_folder_project = "terraform_ec2"
    s3_folder_region = "us-east-1"
    s3_folder_type = "class"
    s3_tfstate_file = "infrastructure.tfstate"
    environment = \"${(env.BRANCH_NAME ==~ "dev.*")}\"
    region      = \"${aws_region_var}\"
    public_key  = \"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDXUI8Mt0W/65CPA5rnR4auE8qVb08c6qR9Ca0yQaz9xM6EuShYX8jmktYbrdCIkZTMXbRF58CkWID/NHjYX4ZWZHwLi5uf2RfQegF67+kv6yJ2cgG4AsxUmWqlznxvm9615r8tpzBkKgsya58H+4aPRKqLJmhRm3ZZCa7t2HE7S+RR7fq+WtaQ3BMaKog9AVfHSEP8Gp4Ho7WUv5YlLXu5hlYC+m2oxrSCqXRFIhDtDuyphkzS93gDy8EVBkWnJFkoXT2LbVydcJaNCpEdjB1YFEEc1kMOXCAZ0w5N8PiWgdlY0lPeRXdH1RLX+WCM5FVOT9ujrq8PTQSYIkl2pek3 ikambarov@Islams-MacBook-Pro.local\"
    ami_id      = \"${params.ami_id}\"
"""

node {
    stage('Pull Repo') {
        git url: 'https://github.com/vitaliejicol/packer.works'
    }

    def ami_name = "apache-${UUID.randomUUID().toString()}"
    withCredentials([usernamePassword(credentialsId: 'jenkins-aws-access-key', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
        withEnv(["AWS_REGION=${aws_region_var}", "PACKER_AMI_NAME=${ami_name}"]) {
            stage('Packer Validate') {
                sh 'packer validate worker_prepare.json'
            }
            def ami_id = ''
            stage('Packer Build') {
                //sh 'packer build worker_prepare.json | tee output.txt'

                //ami_id = sh(script: "cat output.txt | grep ${aws_region_var} | awk '{print \$2}' ", returnStdout: true).trim()
                //println(ami_id)
                ami_id = "ami-091bece8f6ae5ae7f"
            }

            stage("Pull Repo"){
                cleanWs()
                git url: 'https://github.com/vitaliejicol/terraform-ec2.git'
    }

            stage("Terrraform Init"){
                writeFile file: "${(env.BRANCH_NAME ==~ "dev.*")}.tfvars", text: "${tf_vars}"
                sh """
                    bash setenv.sh ${environment}.tfvars
                    terraform-0.13 init
                """
            }        
            
            if (terraform_apply.toBoolean()) {
                stage("Terraform Apply"){
                    sh """
                        terraform-0.13 apply -var-file ${environment}.tfvars -auto-approve
                    """
                }
            }
            else if (terraform_destroy.toBoolean()) {
                stage("Terraform Destroy"){
                    sh """
                        terraform-0.13 destroy -var-file ${environment}.tfvars -auto-approve
                    """
                }
            }
            else {
                stage("Terraform Plan"){
                    sh """
                        terraform-0.13 plan -var-file ${environment}.tfvars
                    """
                }
            }
        }  
    }
}
