FROM nginx:stable-alpine

COPY pkgs/ /usr/share/nginx/html/
