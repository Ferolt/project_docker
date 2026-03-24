FROM node:20-bookworm-slim AS build

WORKDIR /app

RUN chown node:node /app

COPY --chown=node:node package*.json ./

USER node

RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi \
    && npm cache clean --force

COPY --chown=node:node . .

RUN npm run build

FROM node:20-bookworm-slim AS runtime

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=8080

RUN chown node:node /app

COPY --chown=node:node package*.json ./

USER node

RUN if [ -f package-lock.json ]; then npm ci --omit=dev; else npm install --omit=dev; fi \
    && npm cache clean --force

COPY --from=build --chown=node:node /app/dist ./dist
COPY --chown=node:node server.cjs ./server.cjs

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://127.0.0.1:' + (process.env.PORT || 8080) + '/', (r) => process.exit(r.statusCode < 500 ? 0 : 1)).on('error', () => process.exit(1))"

CMD ["node", "server.cjs"]
