## Build/Push Docker image
```
docker build -t mickelonius/kubernetes-fastapi:1.0.0 .
docker run -p 8080:8080 --name kubernetes-fastapi mickelonius/kubernetes-fastapi:1.0.0
docker push mickelonius/kubernetes-fastapi:1.0.0
```

```
$ pip install locust
$ locust
```