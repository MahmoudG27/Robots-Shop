FROM nginx:1.25-alpine

# Security: non-root user
RUN addgroup -S nginx && adduser -S nginx -G nginx

# Remove default config
RUN rm /etc/nginx/conf.d/default.conf

# Copy configs & static files
COPY default.conf.template /etc/nginx/templates/default.conf.template
COPY static /usr/share/nginx/html
COPY entrypoint.sh /entrypoint.sh

# Permissions
RUN chmod +x /entrypoint.sh \
    && chown -R nginx:nginx /usr/share/nginx/html

USER nginx

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]