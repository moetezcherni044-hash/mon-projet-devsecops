pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo '=== Étape 1 : Récupération du code depuis GitHub ==='
                git url: 'https://github.com/moetezcherni044-hash/mon-projet-devsecops.git', branch: 'main'
            }
        }

        stage('Build Maven') {
            steps {
                echo '=== Étape 2 : Compilation et Tests Spring Boot ==='
                sh '''
                    docker rm -f temp-maven-build || true
                    docker create --name temp-maven-build maven:3.9.6-eclipse-temurin-17 sleep 600
                    docker start temp-maven-build
                    docker cp . temp-maven-build:/app
                    docker exec -w /app temp-maven-build mvn clean package
                    docker cp temp-maven-build:/app/target ./target
                    docker rm -f temp-maven-build
                '''
            }
        }

        stage('SAST - SonarQube Analysis') {
            steps {
                echo '=== Étape 3 : Analyse statique du code (SAST) ==='
                sh '''
                    docker rm -f temp-sonar-build || true
                    docker create --name temp-sonar-build --add-host=host.docker.internal:host-gateway maven:3.9.6-eclipse-temurin-17 sleep 600
                    docker start temp-sonar-build
                    docker cp . temp-sonar-build:/app
                    docker exec -w /app temp-sonar-build mvn sonar:sonar -Dsonar.projectKey=mon-projet-devsecops -Dsonar.host.url=http://host.docker.internal:9000 -Dsonar.login=sqa_28ad1f4873c762f0ec64b6f93540bf91ba2a4e83
                    docker rm -f temp-sonar-build
                '''
            }
        }

        stage('Docker Build') {
            steps {
                echo '=== Étape 4 : Construction de l\'image Docker ==='
                sh 'docker build -t mon-projet-devsecops:latest .'
            }
        }

        stage('Container Scan - Trivy') {
            steps {
                echo '=== Étape 5 : Scan de vulnérabilités du conteneur (Trivy) ==='
                sh 'docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --severity HIGH,CRITICAL mon-projet-devsecops:latest'
            }
        }
    }

    post {
        success {
            echo '=== Pipeline DevSecOps exécuté avec succès ! ==='
        }
        failure {
            echo '=== Le pipeline a échoué (erreur de build ou faille critique détectée) ==='
        }
    }
}
