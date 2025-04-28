# Use latest stable channel SDK.
FROM dart:stable AS build

# Defina o ambiente
ENV API_KEY_GEMINI="AIzaSyAeYV6fJV5KjxN8g1Zjlfw0CCeUYtloFjM"
ENV API_KEY_CHATGPT="sk-proj-ASl8dAsovhX3OAq6AGvGT3BlbkFJV9MB869wapMddLlRvLDa"
ENV OLLAMA_MODEL="llama3"

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* ./
COPY dnose.properties ./
RUN dart pub get

# Copy app source code (except anything in .dockerignore) and AOT compile app.
COPY . .
RUN dart run build_runner build
RUN dart compile exe bin/dnose.dart -o bin/dnose

# Ensure binary has execute permissions
RUN chmod +x /app/bin/dnose

# Use Alpine as a minimal base image

FROM alpine:latest
# Instala sqlite, sqlite-libs, sqlite3 (CLI) e git
RUN apk update && apk add --no-cache sqlite sqlite-libs sqlite-dev git
# RUN ln -s /usr/lib/libsqlite3.so.0 /usr/lib/libsqlite3.so   
COPY --from=build /app/sqlite3 /app/sqlite3
COPY --from=build /app/libsqlite3.so /app/libsqlite3.so
COPY --from=build /runtime/ /
COPY --from=build /app/bin/dnose /app/bin/
COPY --from=build /app/dnose.properties /app/
COPY --from=build /app/lib /app/lib
COPY --from=build /app/public /app/public

# Start server.
EXPOSE 8080
WORKDIR /app
CMD ["/app/bin/dnose"]
