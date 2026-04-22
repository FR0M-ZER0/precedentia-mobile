FROM ghcr.io/cirruslabs/flutter:stable AS build


USER root
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

RUN git config --global --add safe.directory /sdks/flutter
RUN flutter config --no-analytics
RUN flutter pub get
RUN flutter build web --release

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
