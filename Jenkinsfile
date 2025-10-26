// pipeline {
//   agent any

//   environment {
//     AWS_CREDENTIALS_ID = 'aws-cred'
//     TF_BACKEND_BUCKET  = 'terraform-state-jenkins5533'
//     TF_BACKEND_REGION  = 'us-east-1'
//   }

//   stages {
//     stage('Checkout') {
//       steps {
//         checkout scm
//       }
//     }

//     stage('Setup AWS Credentials') {
//       steps {
//         withAWS(credentials: "${AWS_CREDENTIALS_ID}", region: "${TF_BACKEND_REGION}") {
//           echo "✅ AWS credentials configured."
//         }
//       }
//     }

//     stage('Terraform Init') {
//     steps {
//         timeout(time: 5, unit: 'MINUTES') {
//         sh '''
//             set -e
//             rm -rf .terraform .terraform.lock.hcl
//             terraform init -input=false -no-color -reconfigure \
//             -backend-config="bucket=terraform-state-jenkins5533" \
//             -backend-config="region=us-east-1"
//         '''
//         }
//     }
//     }


//     stage('Terraform Validate') {
//       steps {
//         timeout(time: 5, unit: 'MINUTES') {
//           sh '''
//             set -e
//             terraform validate
//             echo "✅ Terraform validation successful."
//           '''
//         }
//       }
//     }

//     stage('Terraform Plan') {
//       steps {
//         timeout(time: 10, unit: 'MINUTES') {
//           sh '''
//             set -e
//             terraform plan -out=tfplan
//             echo "✅ Terraform plan completed."
//           '''
//         }
//       }
//     }

//     stage('Terraform Apply') {
//       steps {
//         input message: 'Approve to apply Terraform changes?'
//         timeout(time: 10, unit: 'MINUTES') {
//           sh '''
//             set -e
//             terraform apply -auto-approve tfplan
//             echo "✅ Terraform apply completed successfully."
//           '''
//         }
//       }
//     }
//   }
// }


pipeline {
  agent any

  environment {
    AWS_CREDENTIALS_ID = 'aws-cred'
    TF_BACKEND_BUCKET  = 'terraform-state-jenkins5533'
    TF_BACKEND_REGION  = 'us-east-1'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Setup AWS Credentials') {
      steps {
        withAWS(credentials: "${AWS_CREDENTIALS_ID}", region: "${TF_BACKEND_REGION}") {
          echo "✅ AWS credentials configured."
        }
      }
    }

    stage('Terraform Init') {
      steps {
        sh '''
          set -e
          rm -rf .terraform .terraform.lock.hcl
          terraform init -input=false -no-color -reconfigure \
            -backend-config="bucket=${TF_BACKEND_BUCKET}" \
            -backend-config="region=${TF_BACKEND_REGION}"
        '''
      }
    }

    stage('Terraform Validate') {
      steps {
        sh '''
          set -e
          terraform validate
          echo "✅ Terraform validation successful."
        '''
      }
    }

    stage('Terraform Plan') {
      steps {
        sh '''
          set -e
          terraform plan -out=tfplan
          echo "✅ Terraform plan completed."
        '''
      }
    }

    stage('Terraform Apply') {
      steps {
        input message: 'Approve to apply Terraform changes?'
        sh '''
          set -e
          terraform apply -auto-approve tfplan
          echo "✅ Terraform apply completed successfully"
        '''
      }
    }
  }
}
