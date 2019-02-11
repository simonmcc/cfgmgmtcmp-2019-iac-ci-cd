// Declarative Jenkinsfile Pipeline for a Hashicorp packer/terraform AWS simple ec2 stack
// (n.b. use of env.BRANCH_NAME to filter stages based on branch means this needs to be part
// of a Multibranch Project in Jenkins - this fits with the model of branches/PR's being
// tested & master being deployed)
pipeline {
  agent any
  environment {
    AWS_DEFAULT_REGION = 'us-east-1'
    AWS_CRED = credentials('demo-aws-creds-up')
    DEBUG = 0
  }

  stages {
    stage('Validate & lint') {
      parallel {
        stage('packer validate') {
          agent {
            docker {
              image 'simonmcc/hashicorp-pipeline:latest'
              alwaysPull true
            }
          }
          steps {
            checkout scm
            wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
              sh "packer validate ./base/base.json"
              sh "AMI_BASE=ami-fakefake packer validate app/app.json"
            }
          }
        }
        stage('terraform fmt') {
          agent {
            docker {
              image 'simonmcc/hashicorp-pipeline:latest'
              alwaysPull true
            }
          }
          steps {
            checkout scm
            sh "terraform fmt -check=true -diff=true"
          }
        }
      }
    }
    stage('build AMIs') {
      agent {
        docker {
          image 'simonmcc/hashicorp-pipeline:latest'
          // yes, this is horrible, but something is broken in withCredentials & docker agents
          args "--env AWS_ACCESS_KEY_ID=${AWS_CRED_USR} --env AWS_SECRET_ACCESS_KEY=${AWS_CRED_PSW}"
        }
      }
      steps {
        checkout scm
        wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
          sh "cd packer-vpc ; terraform init ; terraform apply -auto-approve"
          sh "./scripts/build.sh base base"
          sh "./scripts/build.sh app app"
        }
      }
    }

    stage('build test stack') {
      agent {
        docker {
          image 'simonmcc/hashicorp-pipeline:latest'
          // yes, this is horrible, but something is broken in withCredentials & docker agents
          args "--env AWS_ACCESS_KEY_ID=${AWS_CRED_USR} --env AWS_SECRET_ACCESS_KEY=${AWS_CRED_PSW}"
        }
      }
      when {
        expression { env.BRANCH_NAME != 'master' }
      }
      steps {
        checkout scm
        wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
          sh "cat backend_config.tf"
          sh "./scripts/tf-wrapper.sh -a plan"
          sh "./scripts/tf-wrapper.sh -a apply"
          sh "cat output.json"
          stash name: 'terraform_output', includes: '**/output.json'
        }
      }
      post {
        failure {
          wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
            sh "./scripts/tf-wrapper.sh -a destroy"
          }
        }
      }
    }
    stage('test test stack') {
      agent {
        docker {
          image 'chef/inspec:latest'
          // yes, this is horrible, but something is broken in withCredentials & docker agents
          args "--entrypoint='' --env AWS_ACCESS_KEY_ID=${AWS_CRED_USR} --env AWS_SECRET_ACCESS_KEY=${AWS_CRED_PSW}"
        }
      }
      when {
        expression { env.BRANCH_NAME != 'master' }
      }
      steps {
        checkout scm
        wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
          unstash 'terraform_output'
          sh "cat output.json"
          sh "mkdir aws-security/files || true"
          sh "mkdir test-results || true"
          sh "cp output.json aws-security/files/output.json"
          // give the stack time to finish starting..
          sh "sleep 30"
          sh "inspec exec aws-security --reporter=cli junit:test-results/inspec-aws-junit.xml --controls aws-1.0 -t aws://us-east-1"
          sh "inspec exec aws-security --reporter=cli junit:test-results/inspec-web-junit.xml --controls web-1.0"
          sh "touch test-results/inspec-junit.xml"
        }
      }
      post {
        always {
          junit 'test-results/*.xml'
        }
      }
    }
    stage('destroy test stack') {
      agent {
        docker {
          image 'simonmcc/hashicorp-pipeline:latest'
          // yes, this is horrible, but something is broken in withCredentials & docker agents
          args "--env AWS_ACCESS_KEY_ID=${AWS_CRED_USR} --env AWS_SECRET_ACCESS_KEY=${AWS_CRED_PSW}"
        }
      }
      when {
        expression { env.BRANCH_NAME != 'master' }
      }
      steps {
        checkout scm
        wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
          sh "./scripts/tf-wrapper.sh -a destroy"
        }
      }
    }

    stage('terraform plan - master') {
      agent {
        docker {
          image 'simonmcc/hashicorp-pipeline:latest'
          // yes, this is horrible, but something is broken in withCredentials & docker agents
          args "--env AWS_ACCESS_KEY_ID=${AWS_CRED_USR} --env AWS_SECRET_ACCESS_KEY=${AWS_CRED_PSW}"
        }
      }
      when {
        expression { env.BRANCH_NAME == 'master' }
      }
      steps {
        checkout scm
        wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
          sh "./scripts/tf-wrapper.sh -a plan"
          stash name: 'terraform_plan', includes: 'plan/plan.out,.terraform/**'
        }
      }
    }
    stage('Manual Approval') {
      when {
        expression { env.BRANCH_NAME == 'master' }
      }
      steps {
        input 'Do you approve the apply?'
      }
    }
    stage('terraform apply - master') {
      agent {
        docker {
          image 'simonmcc/hashicorp-pipeline:latest'
          // yes, this is horrible, but something is broken in withCredentials & docker agents
          args "--env AWS_ACCESS_KEY_ID=${AWS_CRED_USR} --env AWS_SECRET_ACCESS_KEY=${AWS_CRED_PSW}"
        }
      }
      when {
        expression { env.BRANCH_NAME == 'master' }
      }
      steps {
        checkout scm
        wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
          unstash 'terraform_plan'
          sh "./scripts/tf-wrapper.sh -a apply"
        }
      }
    }
  }
  post {
    // always run a "terraform destroy", as the build-test-destroy chain will skip the destroy step of test fails
    always {
      // drop to scripted mode pipeline so that we can specify a node for the post stage to run on
      script {
        if(env.BRANCH_NAME != "master") {
          checkout scm
          docker.image("simonmcc/hashicorp-pipeline:latest").inside("--env AWS_ACCESS_KEY_ID=${AWS_CRED_USR} --env AWS_SECRET_ACCESS_KEY=${AWS_CRED_PSW}") {
            sh "./scripts/tf-wrapper.sh -a destroy"
          }
        }
      }
    }
    cleanup {
      cleanWs()
    }
  }
}
