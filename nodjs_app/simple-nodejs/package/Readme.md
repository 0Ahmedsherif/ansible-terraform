#### 1. Application setup steps

  Some new line here to test blabl

This simple nodejs app starts on port 3000 and logs 1 line into elastic search which is running in a minikube cluster. Elastic endpoint configured in Pino is the es service name in Minikube.

###### to prepare the app for startup, installing all the dependencies 
    
    npm install

###### to start the application

    npm start or node app/server.js

###### to build the image from Dockerfile

    docker build -t nodejs-app:1.0 .

###### to start the built docker image

    docker run nodejs-app:1.0


#### 2. Deploy on Minikube

(pre-requisite elastic search setup in Minikube)

###### build the uptodate image INSIDE MINIKUBE (this way docker won't have to pull the image from repo, it will take the one existing locally)

Set docker remote to Minikube's docker

    eval $(minikube docker-env) 

Build image inside Minikube

    docker build -t nodejs-app:1.0 .

###### deploy pod from the image

    kubectl apply -f pod.yaml

