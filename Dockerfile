FROM mcr.microsoft.com/devcontainers/typescript-node:22-bookworm

# Install deps
RUN apt-get update && apt-get install -y \
    build-essential \
    g++ \
    libx11-dev \
    libxkbfile-dev \
    libsecret-1-dev \
    libkrb5-dev \
    python-is-python3 \
    git \
    curl \
    tar

# Set working directory
WORKDIR /app

# Copy source
COPY . source/

# Install dependencies & build
RUN cd source && \
    npm ci && \
    npm run compile-build && \
    npm run minify-vscode-reh-web && \
    npm run gulp vscode-reh-web-linux-x64-min-ci && \
    npm run extensions-ci

# Copy extensions & move the built output to the working directory
RUN mkdir -p /root/.vscode-server-devant/extensions && \
    cp -a source/.build/extensions/. /root/.vscode-server-devant/extensions && \
    cp -a vscode-reh-web-linux-x64/. . && \
    rm -r vscode-reh-web-linux-x64 && \
    rm -rf source

# Download & install Ballerina & Java
RUN curl -o /tmp/ballerina-2201.12.3-swan-lake-linux-x64.deb https://dist.ballerina.io/downloads/2201.12.3/ballerina-2201.12.3-swan-lake-linux-x64.deb && \
    dpkg -i /tmp/ballerina-2201.12.3-swan-lake-linux-x64.deb && \
    rm /tmp/ballerina-2201.12.3-swan-lake-linux-x64.deb

# Create a sample project with Ballerina
RUN mkdir -p /opt/project-template \
    && git clone https://github.com/gigara/ballerina-integrator-empty-proj.git /tmp/ballerina-integrator-empty-proj \
    && cp -a /tmp/ballerina-integrator-empty-proj/1.0.0/. /opt/project-template/ \
    && rm -rf /tmp/ballerina-integrator-empty-proj

# Expose the port the code server will run on
EXPOSE 8081

ENV HOST="localhost:8081"

# Start the server
CMD ["/app/bin/code-server-devant", "--host", "0.0.0.0", "--port", "8081", "--default-folder", "/opt/project-template", "--connection-token", "giga", "--disable-workspace-trust", "--extensions-dir", "/root/.vscode-server-devant/extensions"]

# Set the working directory
WORKDIR /opt/project-template
