#!/bin/bash

#This file should be in the root directory containing the frontend and the backend

# Build the React app image
docker build -t frontend-app-image ./smartschool-fe -f ./smartschool-fe/Dockerfile-fe

# Build the Node.js server image
docker build -t backend-server-image ./smartschool_be/be -f ./smartschool_be/be/Dockerfile-be

# Build the PDF server server image
docker build -t pdf-server-image ./smartschool_be/be-pdf -f ./smartschool_be/be-pdf/Dockerfile-pdf

# Build the Node.js server image
docker build -t database-server-image ./smartschool_be/db -f ./smartschool_be/db/Dockerfile-db

# Create a network to connect all containers
docker network create smartschool-network

# Start the Node.js server container
docker run --name smartschool-be --network smartschool-network -d -p 4000:4000 -v ./smartschool_be/be/:/app/ backend-server-image

# Start the pdf server container
docker run --name smartschool-pdf --network smartschool-network -d -p 6000:6000 -v ./smartschool_be/be-pdf/:/app/ pdf-server-image

# Start the React app container
docker run --name smartschool-fe --network smartschool-network -d -p 3000:3000 -v ./smartschool-fe/:/app/ frontend-app-image

# Run start the database
docker run --name smartschool-db --network smartschool-network -d -p 5432:5432 -v ./smartschool_be/db/:/app/ database-server-image