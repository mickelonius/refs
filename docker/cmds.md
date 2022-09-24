
## Getting most of Dockerfile from a pull
```
> alias dfimage="docker run -v /var/run/docker.sock:/var/run/docker.sock --rm alpine/dfimage"
> dfimage -sV=1.36 traefik/traefikee-webapp-demo:v2

COPY file:c8f727cb8b17c5a8735e609a9b9f333f20765e36c457d0557ed48693a6694880 in /etc/ssl/certs/
        etc/
        etc/ssl/
        etc/ssl/certs/
        etc/ssl/certs/ca-certificates.crt

COPY file:ad4229d63a8ce1fa9e23a26667f1243f66e6845d430a6f4c0f348003e9b76669 in .
        whoami

COPY dir:c28d8075a73407d457a3b099a46e92ec02b46f8a08e133207b600762c73813fb in ./templates
        templates/
        templates/index.html

ENTRYPOINT ["/whoami"]
EXPOSE 80
```