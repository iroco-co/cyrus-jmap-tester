# cyrus-jmap-tester

Cyrus JMAP server image for integration testing.

This is a work in progress.

## Build

The usual docker build command:

```shell
docker build -t cyrus-jmap-tester .
```

## Run

You must map the httpd port from cyrus (8080) and provide a JWT secret:

```shell
docker run -ti -p 8080:8080 -e JWT_SECRET=hex_secret cyrus-jmap-tester
```
