def aws_region_var = ''
def environment = ''

if(params.environment ==~ "dev-*"){
    aws_region_var = "us-east-1"
    environment = 'dev'
}
else if(params.environment ==~ "qa-*"){
    aws_region_var = "us-east-2"
    environment = 'qa'
}
else if(params.environment ==~ "prod-*"){
    aws_region_var = "us-west-2"
    environment = 'prod'
}

node {
    stage('Pull Repo') {
        git url: 'https://github.com/vitaliejicol/packer.works.git'
    }
    def ami_name = "apache-${UUID.randomUUID().toString()}"
    withCredentials([usernamePassword(credentialsId: 'jenkins-aws-access-key', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
        withEnv(["AWS_REGION=${aws_region_var}", "PACKER_AMI_NAME=apache-${UUID.randomUUID().toString()}"]) {
            stage('Packer Validate') {
                sh 'packer validate packer_works.json'
            }
            def ami_id = ''
            stage('Packer Build') {
                sh 'packer build packer_works.json | tee output.txt'

                def ami_id = sh(script: "cat output.txt | grep ${aws_region_var} | awk \'{print \$2}\'", returnStdout: true).trim()
                println(ami_id)
            }
        }  
    }
}
