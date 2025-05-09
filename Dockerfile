FROM node:20-slim

# Install deps
RUN apt-get update && apt-get install -y \
    build-essential \
    g++ \
    libx11-dev \
    libxkbfile-dev \
    libsecret-1-dev \
    libkrb5-dev \
    python-is-python3 \
    git

# Set working directory
WORKDIR /app

# Copy source
COPY . source/

# Install dependencies
RUN cd source && \
    npm ci

# Build the project
RUN cd source && \
    npm run gulp vscode-reh-web-linux-x64

# Delete source
RUN rm -rf source

# move the built output to the working directory
RUN mv vscode-reh-web-linux-x64/ ./

# Expose the port the code server will run on
EXPOSE 8080

# Start the server
CMD ["./bin/code-server-devant", "--host", "0.0.0.0", "--port", "8080"]
