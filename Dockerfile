FROM --platform=$BUILDPLATFORM gradle:6.8.3-jdk11 AS build
ARG RELEASE_MODE
ARG APP_VERSION
WORKDIR /usr/app
COPY . /usr/app
RUN if [ "${RELEASE_MODE}" = true ]; then \
    gradle build --no-build-cache --exclude-task test \
        -PreleaseMode=true \
        -Dorg.gradle.project.version=${APP_VERSION}; \
    else gradle build --no-build-cache --exclude-task test -Dorg.gradle.project.version=${APP_VERSION}; fi

# For ARM build use flag: `--platform linux/arm64`
FROM --platform=$BUILDPLATFORM amazoncorretto:11.0.20
ARG APP_VERSION
LABEL version=${APP_VERSION} description="EPAM ReportPortal. Auth Service" maintainer="Andrei Varabyeu <andrei_varabyeu@epam.com>, Hleb Kanonik <hleb_kanonik@epam.com>"
ENV APP_DIR=/usr/app
ENV JAVA_OPTS="-Xmx1g -XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=70 -Djava.security.egd=file:/dev/./urandom"
WORKDIR $APP_DIR
COPY --from=build $APP_DIR/build/libs/service-authorization-*exec.jar .
VOLUME ["/tmp"]
EXPOSE 8080
ENTRYPOINT exec java ${JAVA_OPTS} -jar ${APP_DIR}/service-authorization-*exec.jar
