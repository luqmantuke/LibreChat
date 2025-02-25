# v0.7.7-rc1 - Modified for Cloud Run

# Base node image
FROM node:20-alpine AS node

RUN apk --no-cache add curl

RUN mkdir -p /app && chown node:node /app
WORKDIR /app

USER node

# Copy project files with appropriate ownership
COPY --chown=node:node . .
# Log that files are copied (gets executed during the run phase, or can be seen during build if RUN is used)
RUN echo "Copied project files to container."

# Further setup steps
RUN \
    # Copy the example environment config to the active config
    cp .env.example .env && \
    # Create directories for the volumes to inherit the correct permissions
    mkdir -p /app/client/public/images /app/api/logs && \
    # Set npm configuration to handle retries
    npm config set fetch-retry-maxtimeout 600000 && \
    npm config set fetch-retries 5 && \
    npm config set fetch-retry-mintimeout 15000 && \
    # Install dependencies without saving audit information
    npm install --no-audit && \
    # If there's a build step for a frontend application
    NODE_OPTIONS="--max-old-space-size=2048" npm run frontend && \
    # Remove unnecessary packages
    npm prune --production && \
    # Clean up npm cache
    npm cache clean --force

# Expose the port on which the app runs
EXPOSE 3080
ENV PORT=3080
ENV HOST=0.0.0.0

# Command to run the application
CMD ["npm", "run", "backend"]