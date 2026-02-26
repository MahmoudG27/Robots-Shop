# Build stage
FROM maven:3.9.6-eclipse-temurin-11 AS build

WORKDIR /build
COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn package -DskipTests

# Runtime stage
FROM eclipse-temurin:11-jre-alpine

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /opt/shipping

ENV JAVA_OPTS="-XX:MaxRAMPercentage=75"

COPY --from=build /build/target/shipping-1.1.0.jar app.jar

EXPOSE 8080

USER appuser

CMD ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
