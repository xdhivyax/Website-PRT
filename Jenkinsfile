pipeline{
    agent any
    stages{
        stage("clone"){
            agent{
                label 'kube-master'
            }
            steps{
                git branch: 'main', url: 'https://github.com/xdhivyax/Website-PRT.git'
            }
            }
        
        stage("docker-image")  {
            agent{
                label 'kube-master'
            }
            steps{
                sh 'cd $WORSPACE'
                sh 'sudo docker build -f Dockerfile -t dhivya2409/prt .'
                withCredentials([string(credentialsId: 'DOCKER_HUB_PASSWORD', variable: 'DOCKER_HUB_PASSWORD')]) {
                            sh "sudo docker login -u dhivya2409 -p ${DOCKER_HUB_PASSWORD}"
}
                sh 'sudo docker push dhivya2409/prt'
             }
        }
        stage("deploy"){
            agent{
                label 'kube-master'
            }
            steps{
                sh 'kubectl apply -f deploy.yaml'
                sh 'kubectl apply -f svc.yaml'
            }
        }
    }
}


