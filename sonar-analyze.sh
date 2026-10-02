#!/bin/bash
set -e

CONTAINER_NAME="temp-sonar-build"
SONAR_SERVER="http://host.docker.internal:9000"
SONAR_TOKEN="sqa_26906cd6c93d01a68c3fa33f7e7138001a561ded"

# 1. Nettoyage préventif au cas où un ancien conteneur existerait encore
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

# 2. Lancement d'un conteneur persistant
echo "Lancement du conteneur temporaire..."
docker run -d --name "$CONTAINER_NAME" \
  --add-host=host.docker.internal:host-gateway \
  maven:3.9.6-eclipse-temurin-17 sleep infinity

# Utilisation de 'trap' pour garantir le nettoyage du conteneur en fin de script
trap 'docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1' EXIT

# 3. Copie du code source dans le conteneur
echo "Copie du code source..."
docker cp . "$CONTAINER_NAME:/app"

# 4. Exécution de Maven et SonarQube avec sonar.login au lieu de sonar.token
echo "Exécution de l'analyse SonarQube..."
docker exec -w /app "$CONTAINER_NAME" mvn clean verify org.sonarsource.scanner.maven:sonar-maven-plugin:sonar \
  -Dsonar.host.url="$SONAR_SERVER" \
  -Dsonar.login="$SONAR_TOKEN"

echo "Analyse terminée avec succès !"
