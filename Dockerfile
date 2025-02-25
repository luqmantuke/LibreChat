# Base node image
FROM node:20-alpine AS node

RUN apk --no-cache add curl

RUN mkdir -p /app && chown node:node /app
WORKDIR /app

USER node

# Copy project files with appropriate ownership
COPY --chown=node:node . .
RUN echo "Copied project files to container."
RUN ls -la  # List files in /app to check contents

RUN \
    cp .env.example .env && \
    mkdir -p /app/client/public/images /app/api/logs && \
    npm config set fetch-retry-maxtimeout 600000 && \
    npm config set fetch-retries 5 && \
    npm config set fetch-retry-mintimeout 15000 && \
    npm install --no-audit && \
    NODE_OPTIONS="--max-old-space-size=2048" npm run frontend && \
    npm prune --production && \
    npm cache clean --force

EXPOSE 3080
ENV PORT=3080
ENV HOST=0.0.0.0

CMD ["npm", "run", "backend"]