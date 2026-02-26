FROM node:20-alpine

# Security & best practice
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /opt/server

COPY package.json package-lock.json ./
RUN npm ci --omit=dev

COPY server.js ./

ENV NODE_ENV=production

EXPOSE 8080

USER appuser

# HEALTHCHECK --interval=30s --timeout=5s --start-period=10s \
#  CMD wget -qO- http://localhost:8080/health || exit 1

CMD ["node", "server.js"]
