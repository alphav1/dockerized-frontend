# Retrieve the official base image from Docker Hub, create a new build stage (FROM)
FROM node:22-alpine AS builder
# Set the working directory inside the image/container
WORKDIR /app

# Copy configuration files first (* means both package.json and package-lock.json)
COPY package*.json ./

# Install dependencies
# npm ci npm - npm clean-install - reads the package-lock. json file to determine the project's package versions and dependencies.
RUN npm ci

# Copy source files (source is from where it is now in the dockerfile and destination is where it currently is in the image, copies all)
COPY . .

# Build the application (Execute build commands)
RUN npm run build
# Execute the build script defined in package.json, compile bundle and optimize the application
# Creates the files in the build directory
RUN npm prune --production
# Remove unnecessary files and development dependencies after the build is complete
# --production flag tells npm to not install devDependencies

# Production stage
# Create a new build stage (FROM), similar to the previous one
FROM node:22-alpine
WORKDIR /app

# Copy built application from .svelte-kit directory
COPY --from=builder /app/build ./build
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json .

# These commands copy the necessary files from the builder stage:
# - The compiled application from the build directory
# - Production node_modules (already pruned in builder stage)
# - package.json for Node.js to properly resolve dependencies

# Expose port
EXPOSE 3000
# EXPOSE describe which ports the application is listening on.
# Set production environment
ENV NODE_ENV=production
# ENV sets the sets Node.js to production mode, which: disables
# development features, optimizes performance, reduces logging

# Start the application
# CMD is the command that is executed when the container starts.
# It specifies the default command to run when the container starts.
# Launches the compiled SvelteKit application using Node.js.
CMD ["node", "build"]