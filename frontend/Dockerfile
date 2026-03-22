FROM node:20-bookworm-slim AS build

WORKDIR /app

ARG NPM_TOKEN=""
ENV NPM_TOKEN=${NPM_TOKEN}

COPY package*.json ./
COPY .npmrc ./

RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi \
    && npm cache clean --force

COPY . .

RUN npm run build

FROM node:20-bookworm-slim AS runtime

WORKDIR /app

ARG NPM_TOKEN=""
ENV NPM_TOKEN=${NPM_TOKEN}
ENV NODE_ENV=production
ENV PORT=8080

COPY package*.json ./
COPY .npmrc ./

RUN if [ -f package-lock.json ]; then npm ci --omit=dev; else npm install --omit=dev; fi \
    && npm cache clean --force

COPY --from=build /app/dist ./dist
COPY --chown=node:node server.cjs ./server.cjs

USER node

EXPOSE 8080

CMD ["npm", "start"]
