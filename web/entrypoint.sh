#!/usr/bin/env sh

set -e

echo "Starting Web Service..."

# generate nginx config from template
envsubst '${CATALOGUE_HOST} ${USER_HOST} ${CART_HOST} ${SHIPPING_HOST} ${PAYMENT_HOST} ${RATINGS_HOST}' \
< /etc/nginx/templates/default.conf.template \
> /etc/nginx/conf.d/default.conf

echo "Nginx config generated"

nginx -g "daemon off;"