FROM gradle:jdk24

RUN mkdir -p /java

COPY ./build/libs/docker-exercises-project-1.0-SNAPSHOT.jar /java/app.jar

WORKDIR /java

CMD ["java", "-jar", "app.jar"]