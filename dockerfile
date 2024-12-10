FROM gradle:jdk17 as builder
WORKDIR /build

COPY build.gradle settings.gradle /build/
RUN gradle build -x test --parallel --continue > /dev/null 2>&1 || true

COPY . /build
RUN gradle build -x test --parallel

FROM openjdk:17.0-slim
WORKDIR /app

COPY --from=builder /build/build/libs/*-SNAPSHOT.jar ./app.jar

# 외부 포트 10000 열기...선언
EXPOSE 8080

# root 대신 nobody 권한으로 실행
# USER nobody
ENTRYPOINT ["java","-jar","-Djava.security.egd=file:/dev/./urandom","-Dsun.net.inetaddr.ttl=0","app.jar"]
