#!/bin/bash
export VER=0.1
#docker login

docker build -t nextjs-materio-test .
#docker run -p 3000:3000 nextjs-materio-test:latest

docker tag nextjs-materio-test mickelonius/nextjs-materio-test:$VER
docker tag nextjs-materio-test mickelonius/nextjs-materio-test:latest

docker push mickelonius/nextjs-materio-test:$VER
docker push mickelonius/nextjs-materio-test:latest
