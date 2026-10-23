FROM node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm npm ci --no-audit --no-fund --maxsockets=5 --fetch-retries=4 --fetch-timeout=60000 --fetch-retry-mintimeout=1000 --fetch-retry-maxtimeout=10000 --loglevel=info
COPY . .
ENV API_URL=http://backend:8080
RUN npm run build
FROM node:22-alpine
WORKDIR /app
ENV NODE_ENV=production API_URL=http://backend:8080 HOSTNAME=0.0.0.0 PORT=3000
COPY --from=build --chown=node:node /app/.next/standalone ./
COPY --from=build --chown=node:node /app/.next/static ./.next/static
COPY --from=build --chown=node:node /app/public ./public
USER node
EXPOSE 3000
CMD ["node", "server.js"]
