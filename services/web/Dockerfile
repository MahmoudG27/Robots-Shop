FROM nginx:1.25-alpine

WORKDIR /app

RUN apk add --no-cache bash curl

RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf.template /etc/nginx/templates/default.conf.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY static /usr/share/nginx/html

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]