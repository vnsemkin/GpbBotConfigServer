#stage 1
#Start with a base image containing Java runtime
FROM openjdk:21-slim as build

# Add Maintainer Info
LABEL maintainer="Vladimir Semkin <vnsemkin@gmail.com>"

# The application's jar file
ARG JAR_FILE=./build/libs/*.jar

# Add the application's jar to the container
COPY ${JAR_FILE} app.jar
COPY config /tmp/config

#unpackage jar file
RUN mkdir -p target/dependency && (cd target/dependency; jar -xf /app.jar)

#stage 2
#Same Java runtime
FROM openjdk:21-slim

#Add volume pointing to /tmp
VOLUME /tmp

#Copy unpackaged application to new container
ARG DEPENDENCY=/target/dependency
COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app
COPY --from=build /tmp/config /app/config

#execute the application
ENTRYPOINT ["java","-cp","app:app/lib/*","org.vnsemkin.gpbbotconfigserver.GpbBotConfigServerApplication"]