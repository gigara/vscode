FROM --platform=linux/amd64 node:20-slim

# Install deps
RUN apt-get update && apt-get install -y \
    build-essential \
    g++ \
    libx11-dev \
    libxkbfile-dev \
    libsecret-1-dev \
    libkrb5-dev \
    python-is-python3

# Set working directory
WORKDIR /app

# Copy the pre-built output from parent directory
COPY ../vscode-server-linux-x64/ .

# Expose the port the code server will run on
EXPOSE 8080

# Start the server
CMD ["./bin/code-server-devant", "--host", "0.0.0.0", "--port", "8080"]
