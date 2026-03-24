FROM node:20-bookworm-slim AS base

WORKDIR /app

RUN chown node:node /app

COPY --chown=node:node package*.json ./

FROM base AS development

USER node

RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi \
    && npm cache clean --force

COPY --chown=node:node . .

ENV NODE_ENV=development
ENV PORT=3002

EXPOSE 3002

CMD ["npm", "run", "dev"]

FROM base AS production

USER node

RUN if [ -f package-lock.json ]; then npm ci --omit=dev; else npm install --omit=dev; fi \
    && npm cache clean --force

COPY --chown=node:node . .

ENV NODE_ENV=production
ENV PORT=3002

EXPOSE 3002

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:' + (process.env.PORT || 3002) + '/api/health').then(r => process.exit(r.ok ? 0 : 1)).catch(() => process.exit(1))"

CMD ["npm", "start"]
