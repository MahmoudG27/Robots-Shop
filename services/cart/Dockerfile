FROM node:20-alpine

WORKDIR /opt/server

RUN apk add --no-cache wget dumb-init

COPY package*.json ./
RUN npm ci --omit=dev --no-audit --no-fund && npm cache clean --force

COPY server.js ./

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN chmod -R 555 /opt/server

USER appuser

ENV NODE_ENV=production

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --retries=2 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health/live || exit 1

ENTRYPOINT ["dumb-init", "--"]

CMD ["node", "server.js"]