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

CMD ["node", "server.js"]