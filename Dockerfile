FROM curlimages/curl:latest AS download
WORKDIR /app
RUN curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.0-stable.tar.xz | tar -xJ

FROM ubuntu:22.04 AS build
COPY --from=download /app/flutter /opt/flutter
ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"
WORKDIR /app
COPY . .
RUN flutter doctor
RUN flutter pub get
RUN flutter build web

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80