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
                // Utilisation des guillemets doubles obligatoires autour de "${WORKSPACE}"
                sh 'docker run --rm -v "${WORKSPACE}":/app -w /app maven:3.9.6-eclipse-temurin-17 mvn clean package'
            }
        }

        stage('SAST - SonarQube Analysis') {
            steps {
                echo '=== Étape 3 : Analyse statique du code (SAST) ==='
                sh 'docker run --rm -v "${WORKSPACE}":/app -w /app maven:3.9.6-eclipse-temurin-17 mvn sonar:sonar -Dsonar.projectKey=mon-projet-devsecops -Dsonar.host.url=http://host.docker.internal:9000 -Dsonar.login=sqa_28ad1f4873c762f0ec64b6f93540bf91ba2a4e83'
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
