FROM mcr.microsoft.com/devcontainers/typescript-node:22-bookworm

COPY .build/extensions/ /root/.vscode-server-devant/extensions
COPY app/ /app

# Download & install Ballerina & Java
RUN curl -o /tmp/ballerina-2201.12.3-swan-lake-linux-x64.deb https://dist.ballerina.io/downloads/2201.12.3/ballerina-2201.12.3-swan-lake-linux-x64.deb && \
    dpkg -i /tmp/ballerina-2201.12.3-swan-lake-linux-x64.deb && \
    rm /tmp/ballerina-2201.12.3-swan-lake-linux-x64.deb

# Create a sample project with Ballerina
RUN mkdir -p /opt/project-template \
    && git clone https://github.com/gigara/ballerina-integrator-empty-proj.git /tmp/ballerina-integrator-empty-proj \
    && cp -a /tmp/ballerina-integrator-empty-proj/1.0.0/. /opt/project-template/

# Expose the port the code server will run on
EXPOSE 8081

ENV HOST="localhost:8081"

# Start the server
CMD ["/app/bin/code-server-devant", "--host", "0.0.0.0", "--port", "8081", "--default-folder", "/opt/project-template", "--connection-token", "giga", "--disable-workspace-trust", "--extensions-dir", "/root/.vscode-server-devant/extensions"]

# Set the working directory
WORKDIR /opt/project-template
