# Etapa 1: Build con Maven
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Copiar pom.xml y descargar dependencias
COPY pom.xml .
RUN mvn dependency:go-offline

# Copiar código fuente y compilar
COPY src ./src
RUN mvn package -DskipTests

# Etapa 2: Runtime
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Copiar JAR
COPY --from=build /app/target/*.jar app.jar

# Usuario no root
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Puerto
EXPOSE 8080

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/ || exit 1

# Comando de inicio
ENTRYPOINT ["java", "-jar", "app.jar"]