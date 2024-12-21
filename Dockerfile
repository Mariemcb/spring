# Utiliser une image OpenJDK officielle
FROM openjdk:17-jdk-slim

# Ajouter le JAR de l'application
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar

# Exposer le port de l'application
EXPOSE 8080

# Commande pour exécuter l'application
ENTRYPOINT ["java", "-jar", "/app.jar"]
