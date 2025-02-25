FROM node:20-alpine AS node

RUN apk --no-cache add curl && echo "Installed curl and other dependencies."

RUN mkdir -p /app && chown node:node /app
RUN echo "Created and set permissions for /app directory."
WORKDIR /app

USER node

# Ensure you handle possible issues when copying files
COPY --chown=node:node . . || echo "Failed to copy files"

RUN \
    echo "Starting application setup..." && \
    cp .env.example .env && echo "Copied environment configuration." || echo "Failed to copy .env.example to .env" && \
    mkdir -p /app/client/public/images /app/api/logs && \
    npm config set fetch-retry-maxtimeout 600000 && \
    npm config set fetch-retries 5 && \
    npm config set fetch-retry-mintimeout 15000 && \
    npm install --no-audit && echo "Dependencies installed." || echo "Failed to install dependencies" && \
    NODE_OPTIONS="--max-old-space-size=2048" npm run frontend && echo "Frontend build complete." || echo "Frontend build failed" && \
    npm prune --production && \
    npm cache clean --force && echo "Cleaned up."

EXPOSE 3080
ENV PORT=3080
ENV HOST=0.0.0.0

CMD ["npm", "run", "backend"]
