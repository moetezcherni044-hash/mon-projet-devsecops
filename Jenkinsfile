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
                    docker run -d --name temp-maven-build maven:3.9.6-eclipse-temurin-17 tail -f /dev/null
                    docker cp . temp-maven-build:/app
                    
                    # Force le nettoyage, la mise à jour et ignore les vieux caches
                    docker exec -w /app temp-maven-build mvn clean package -U
                    
                    # Supprime l'ancien dossier target local pour forcer le remplacement du jar
                    rm -rf ./target
                    docker cp temp-maven-build:/app/target ./target
                    
                    docker rm -f temp-maven-build
                '''
            }
        }

        stage('SAST - SonarQube Analysis') {
            steps {
                echo '=== Étape 3 : Analyse statique du code (SAST) ==='
                withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                    sh '''
                        docker rm -f temp-sonar-build || true
                        docker run -d --name temp-sonar-build --add-host=host.docker.internal:host-gateway maven:3.9.6-eclipse-temurin-17 tail -f /dev/null
                        docker cp . temp-sonar-build:/app
                        docker exec -w /app \
                            -e SONAR_TOKEN="${SONAR_TOKEN}" \
                            temp-sonar-build mvn compile sonar:sonar \
                                -Dsonar.projectKey=mon-projet-devsecops \
                                -Dsonar.host.url=http://host.docker.internal:9000 \
                                -Dsonar.token="${SONAR_TOKEN}"
                        docker rm -f temp-sonar-build
                    '''
                }
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
                sh '''
                    mkdir -p ${WORKSPACE}/.trivycache
                    docker run --rm \
                        -v /var/run/docker.sock:/var/run/docker.sock \
                        -v ${WORKSPACE}/.trivycache:/root/.cache/trivy \
                        aquasec/trivy:latest \
                        image --cache-dir /root/.cache/trivy --severity HIGH,CRITICAL mon-projet-devsecops:latest
                '''
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
