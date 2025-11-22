# Multi-stage build for Node.js Result service
FROM node:18-alpine AS base

# Install security updates
RUN apk --no-cache upgrade

# Create non-root user
RUN addgroup -S result && adduser -S result -G result

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# Copy application code
COPY . .

# Change ownership
RUN chown -R result:result /app

# Switch to non-root user
USER result

# Expose port
EXPOSE 5001

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:5001', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Run application
CMD ["node", "server.js"]
