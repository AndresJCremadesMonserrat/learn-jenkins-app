FROM nginx:1.27-alpine
# We are copying from this local directory (build) into nginx, so that will have this files in our Docker image
COPY build /usr/share/nginx/html 