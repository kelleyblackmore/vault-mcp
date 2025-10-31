# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY tsconfig.json ./

# Copy source code first (needed for prepare script)
COPY src ./src

# Install all dependencies (including dev dependencies needed for build)
# Note: strict-ssl is disabled for build environments with self-signed certificates
RUN npm config set strict-ssl false && npm install

# Production stage
FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install production dependencies only (skip scripts to avoid running prepare/build)
# Note: strict-ssl is disabled for build environments with self-signed certificates
RUN npm config set strict-ssl false && npm ci --omit=dev --ignore-scripts

# Copy built files from builder
COPY --from=builder /app/dist ./dist

# Set environment variables (can be overridden at runtime)
ENV VAULT_ADDR=http://vault:8200
ENV NODE_ENV=production

# Run as non-root user
USER node

# Start the MCP server
ENTRYPOINT ["node", "dist/index.js"]
