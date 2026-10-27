
FROM node:22-alpine AS build

ENV NPM_CONFIG_UPDATE_NOTIFIER=false
ENV NPM_CONFIG_FUND=false

WORKDIR /root

COPY package*.json tsconfig.json ./
COPY src ./src

RUN npm install && \
    npm run build && \
    npm prune --omit=dev

FROM node:22-alpine

WORKDIR /root

# PostgreSQL client tools
ARG PG_VERSION=18

RUN apk add --no-cache \
    postgresql${PG_VERSION}-client

COPY --from=build /root/node_modules ./node_modules
COPY --from=build /root/dist ./dist

CMD ["sh", "-c", "pg_isready --dbname=\"$DATABASE_URL\" && pg_dump --version && exec node dist/index.js"]
