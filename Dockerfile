FROM nginx:1.27-alpine
COPY build /usr/share/nginx/html #We are copying from this local directory (build) into nginx, so that will have this files in our Docker image