# cyrus-jmap-tester

Cyrus JMAP server image for integration testing.

This is a work in progress.

## Run

You must map the httpd port from cyrus (8080) and provide a JWT secret:

```shell
docker run -ti -p 8080:8080 -e JWT_SECRET=hex_secret iroco/cyrus-jmap-tester
```

## Build

With the usual docker build command if you want to customize it:

```shell
docker build -t cyrus-jmap-tester .
```
