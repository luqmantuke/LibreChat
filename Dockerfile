# v0.7.7-rc1 - Modified for Cloud Run

# Base node image
FROM node:20-alpine AS node

# Install curl to fetch .env and docker-compose files
RUN apk --no-cache add curl

# Set up working directory and permissions
RUN mkdir -p /app && chown node:node /app
WORKDIR /app

# Switch to non-root user for security
USER node

# Copy project files
COPY --chown=node:node . .


# List files to ensure .env and docker-compose.override.yml are present
RUN ls -la

# Continue with setup
RUN mkdir -p /app/client/public/images /app/api/logs && \
    npm config set fetch-retry-maxtimeout 600000 && \
    npm config set fetch-retries 5 && \
    npm config set fetch-retry-mintimeout 15000 && \
    npm install --no-audit && \
    NODE_OPTIONS="--max-old-space-size=2048" npm run frontend && \
    npm prune --production && \
    npm cache clean --force

# Expose the port the app runs on and set environment variables
EXPOSE 3080
ENV PORT=3080
ENV HOST=0.0.0.0

# Start the backend server
CMD ["npm", "run", "backend"]
