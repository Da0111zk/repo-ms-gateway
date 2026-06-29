FROM eclipse-temurin:21-jre

WORKDIR /app

ARG JAR_FILE=target/ms-gateway-0.0.1-SNAPSHOT.jar
COPY ${JAR_FILE} app.jar

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]