# ---------- BUILD STAGE ----------
FROM maven:3.9-eclipse-temurin-21 AS build

WORKDIR /build

# Copy only dependency files first (cache optimization)
COPY pom.xml .
COPY mvnw .
COPY .mvn .mvn

RUN ./mvnw dependency:go-offline -B

# Copy source code
COPY src src

# Build jar
RUN ./mvnw package -DskipTests

# ---------- RUNTIME STAGE ----------
FROM gcr.io/distroless/java21-debian12

WORKDIR /app

# Copy only final jar
COPY --from=build /build/target/*.jar app.jar

EXPOSE 8080

# Distroless has no shell → use direct exec form
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
