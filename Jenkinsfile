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
                    docker exec -w /app temp-maven-build mvn clean package
                    docker cp temp-maven-build:/app/target ./target
                    docker rm -f temp-maven-build
                '''
            }
        }

        stage('SAST - SonarQube Analysis') {
            steps {
                echo '=== Étape 3 : Analyse statique du code (SAST) ==='
                // Injection sécurisée du token créé dans Jenkins
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
                    # Crée un dossier de cache local s'il n'existe pas dans le workspace du job
                    mkdir -p ${WORKSPACE}/.trivycache

                    # Lance Trivy en montant le dossier de cache pour éviter de tout retélécharger à chaque build
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
