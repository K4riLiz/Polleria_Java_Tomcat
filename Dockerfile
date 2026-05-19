# Etapa 1: Compilación del proyecto
FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Etapa 2: Imagen liviana con solo el JAR
FROM tomcat:9.0.95-jdk20-temurin-jammy
WORKDIR /usr/local/tomcat
RUN rm -rf webapps/*
COPY --from=builder /app/target/Polleria_Java_Tomcat-1.0-SNAPSHOT.war ./webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]