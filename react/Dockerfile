# Use a Node.js base image for building and serving the React app
FROM node:18 AS builder

# Set working directory inside the container
WORKDIR /app

# Copy package.json and pnpm-lock.yaml (or yarn.lock for yarn) to the working directory
COPY package.json pnpm-lock.yaml /app/
# COPY package.json yarn.lock /app/ (for yarn)

# Install pnpm globally (or use yarn directly) and install dependencies
RUN npm install -g pnpm && \
    pnpm install --frozen-lockfile
# RUN yarn install --frozen-lockfile (for yarn)

# Copy all source code to the working directory
COPY . /app

# Build the React application
RUN pnpm run build
# RUN yarn build (for yarn)

# Use a lightweight Node.js base image for serving the app
FROM node:18-alpine

# Set working directory inside the container
WORKDIR /app

# Copy built files from the builder stage to the working directory
COPY --from=builder /app/dist /app/dist

# Install serve globally to serve static files
RUN npm install -g serve
# RUN yarn global add serve (for yarn)

# Expose port 3000 to the outside world
EXPOSE 3000

# Command to run the Node.js server serving the static files
CMD ["serve", "-s", "dist", "-l", "3000"]
