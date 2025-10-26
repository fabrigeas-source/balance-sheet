# Use official Node.js image as base
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Copy backend files
COPY backend/package*.json ./
COPY backend/index.js ./
COPY backend/public ./public

# Install dependencies
RUN npm install --production

# Expose port
EXPOSE 3000

# Start the app
CMD ["npm", "start"]
