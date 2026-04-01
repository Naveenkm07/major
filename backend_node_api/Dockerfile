FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json first to leverage Docker cache
COPY package*.json ./

# Install dependencies (only production dependencies can be installed if needed: npm ci --only=production)
RUN npm install

# Copy the rest of the application
COPY . .

# Expose the API port
EXPOSE 5000

# Set Node environment to production
ENV NODE_ENV=production

# Start the application
CMD ["npm", "start"]
