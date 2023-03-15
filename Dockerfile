FROM openjdk:17.0.2-slim

EXPOSE 8080

COPY ./target/sample-app-spring-boot-hello*.jar /usr/app/
WORKDIR /usr/app

CMD java -jar sample-app-spring-boot-hello*.jar
