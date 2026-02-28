# Stage 1: Build the application
FROM eclipse-temurin:25-jdk-alpine AS build
WORKDIR /app

# Copy maven/gradle files first to leverage Docker cache
COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN ./mvnw dependency:go-offline

# Copy source and build
COPY src ./src
RUN ./mvnw clean package -DskipTests

# Stage 2: Create the runtime image
FROM eclipse-temurin:25-jre-alpine
WORKDIR /app

# Copy the built jar from the build stage
COPY --from=build /app/target/*.jar app.jar

# Expose the application port
EXPOSE 8761

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]