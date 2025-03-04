# v0.7.7-rc1 - Modified for Cloud Run
FROM node:20-alpine AS node

# Install curl (optional if no longer fetching .env)
RUN apk --no-cache add curl
RUN ls -la
# Set up working directory and permissions
RUN mkdir -p /app && chown node:node /app
RUN ls -la
cp .env.example /app/.env
WORKDIR /app

# Switch to non-root user for security
USER node

# Copy project files
COPY --chown=node:node . .

# Install dependencies and build frontend
RUN npm config set fetch-retry-maxtimeout 600000 && \
    npm config set fetch-retries 5 && \
    npm config set fetch-retry-mintimeout 15000 && \
    npm install --no-audit && \
    NODE_OPTIONS="--max-old-space-size=2048" npm run frontend && \
    npm prune --production && \
    npm cache clean --force

# Create necessary directories
RUN mkdir -p /app/client/public/images /app/api/logs

# Expose port and set environment variables
EXPOSE 3080
ENV PORT=3080
ENV HOST=0.0.0.0

# Start the backend server
CMD ["npm", "run", "backend"]
