pipeline {
    agent any

    environment {
        // Remplacez par votre identifiant Docker Hub ou registry
        IMAGE_NAME = 'moetezcherni044-hash/mon-projet-devsecops'
        TAG = 'latest'
    }

    stages {
        // 1. Récupération du code depuis Git
        stage('Getting Project from Git') {
            steps {
                checkout scm
            }
        }

        // 2. Nettoyage du projet
        stage('cleaning the project') {
            steps {
                sh 'mvn clean'
            }
        }

        // 3. Construction de l'artefact (.jar)
        stage('artifact construction') {
            steps {
                sh 'mvn package -DskipTests'
            }
        }

        // 4. Tests unitaires (JUnit)
        stage('Unit Tests') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

        // 5. Analyse de la qualité du code (SonarQube)
        stage('Code Quality Check via SonarQube') {
            steps {
                // Nécessite d'avoir configuré le serveur SonarQube dans Jenkins
                withSonarQubeEnv('SonarQubeServer') {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        // 6. Publication vers un dépôt d'artefacts (Nexus / Optionnel)
        stage('Publish to Nexus') {
            steps {
                echo 'Publication de l’artefact .jar vers Nexus...'
                // sh 'mvn deploy -DskipTests'
            }
        }

        // 7. Construction de l'image Docker
        stage('Building our image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${TAG} ."
            }
        }

        // 8. Scan de sécurité de l'image (Trivy - Votre touche DevSecOps)
        stage('Container Scan - Trivy') {
            steps {
                sh "trivy image --severity HIGH,CRITICAL ${IMAGE_NAME}:${TAG}"
            }
        }

        // 9. Déploiement de l'image
        stage('Deploy our image') {
            steps {
                echo 'Déploiement de l’application conteneurisée...'
                // Ex: sh "docker run -d -p 8080:8080 ${IMAGE_NAME}:${TAG}"
            }
        }
    }

    post {
        success {
            echo '=== Pipeline DevSecOps exécuté avec succès ! ==='
        }
        failure {
            echo '=== Échec du pipeline (Erreur de build ou de sécurité) ==='
        }
    }
}
