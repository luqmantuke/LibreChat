# v0.7.7-rc1

# Base node image
FROM node:20-alpine AS node

# Install curl and other necessary system packages
RUN apk --no-cache add curl && echo "Installed curl and other dependencies."

# Set up application directory
RUN mkdir -p /app && chown node:node /app && echo "Created and set permissions for /app directory."
WORKDIR /app

# Switch to 'node' user for better security practices
USER node

# Copy project files with appropriate ownership
COPY --chown=node:node . . && echo "Copied project files to container."

# Application setup
RUN \
    # Copy example environment config to active config
    echo "Copying .env.example to .env..." && \
    cp .env.example .env && \
    echo "Environment setup complete." && \
    # Ensure directories are available and have the correct permissions
    mkdir -p /app/client/public/images /app/api/logs && \
    echo "Created directories for images and logs." && \
    # Configuration for npm to handle network issues appropriately
    npm config set fetch-retry-maxtimeout 600000 && \
    npm config set fetch-retries 5 && \
    npm config set fetch-retry-mintimeout 15000 && \
    # Install node modules
    echo "Installing node modules..." && \
    npm install --no-audit && \
    echo "Node modules installed." && \
    # Build frontend assets
    NODE_OPTIONS="--max-old-space-size=2048" npm run frontend && \
    echo "Frontend built successfully." && \
    # Clean up unnecessary dependencies
    npm prune --production && \
    npm cache clean --force && \
    echo "Pruned development dependencies and cleared npm cache."

# Expose the application port
EXPOSE 3080
ENV PORT=3080
ENV HOST=0.0.0.0

# Start the backend server
CMD ["npm", "run", "backend"]
