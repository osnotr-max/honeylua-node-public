FROM node:24-alpine

WORKDIR /app
COPY --chown=node:node package.json ./
COPY --chown=node:node src ./src
COPY --chown=node:node staff-ranking.json ./staff-ranking.json

ENV NODE_ENV=production
ENV NODE_OPTIONS="--max-old-space-size=128 --max-semi-space-size=4"
ENV STAFF_RANKING_FILE=/data/staff-ranking.json

RUN mkdir -p /data && chown node:node /data && node --check src/index.js

USER node
CMD ["node", "src/index.js"]
