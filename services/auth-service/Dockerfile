FROM node:20-bookworm-slim

WORKDIR /app

COPY package*.json ./

RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi \
    && npm cache clean --force

COPY --chown=node:node . .

ENV NODE_ENV=development
ENV PORT=3001

USER node

EXPOSE 3001

CMD ["npm", "run", "dev"]
