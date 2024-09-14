# Use latest stable channel SDK.
FROM dart:stable AS build

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* ./
COPY dnose.properties ./
RUN dart pub get

# Copy app source code (except anything in .dockerignore) and AOT compile app.
COPY . .
RUN dart compile exe bin/server.dart -o bin/server

# Ensure binary has execute permissions
RUN chmod +x /app/bin/server

# Use Alpine as a minimal base image

FROM alpine:latest
RUN apk update && apk add --no-cache sqlite-libs
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/
COPY --from=build /app/dnose.properties /app/
COPY --from=build /app/lib /app/lib
COPY --from=build /app/public /app/public

# Start server.
EXPOSE 8080
WORKDIR /app
CMD ["/app/bin/server"]
