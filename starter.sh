#!/bin/bash

#This file should be in the root directory containing the frontend and the backend

# Build the React app image
docker build -t frontend-app-image ./smartschool-fe -f ./smartschool-fe/Dockerfile-fe

# Build the Node.js server image
docker build -t backend-server-image ./smartschool_be/be -f ./smartschool_be/be/Dockerfile-be

# Start the Node.js server container
docker run -d -p 4000:4000 -v ./smartschool_be/be/:/app/ backend-server-image

# Start the React app container
docker run -d -p 3000:3000 -v ./smartschool-fe/:/app/ frontend-app-image