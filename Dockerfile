FROM eclipse-temurin:17-jre-alpine
EXPOSE 8080
COPY target/mon-projet-1.0.0.jar app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]
