#!/bin/sh
set -e

BASE_DIR=/usr/share/nginx/html

# EUM placeholder (لو عندك frontend JS monitoring)
if [ ! -f "$BASE_DIR/eum.html" ]; then
  cp $BASE_DIR/empty.html $BASE_DIR/eum.html
fi

# Generate nginx config from template
envsubst '${CATALOGUE_HOST} ${USER_HOST} ${CART_HOST} ${SHIPPING_HOST} ${PAYMENT_HOST} ${RATINGS_HOST}' \
  < /etc/nginx/templates/default.conf.template \
  > /etc/nginx/conf.d/default.conf

exec "$@"