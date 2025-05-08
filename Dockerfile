FROM node:20-slim

# Set working directory
WORKDIR /app

# Copy the pre-built output from parent directory
COPY ../vscode-server-linux-x64-web/ .

# Expose the port the code server will run on
EXPOSE 8080

# Start the server
CMD ["./bin/code-server-devant", "--host", "0.0.0.0", "--port", "8080"]
