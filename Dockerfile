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
RUN cp -a vscode-reh-web-linux-x64/. . && \
    rm -r vscode-reh-web-linux-x64

# Download Ballerina
RUN curl -o /tmp/ballerina-2201.12.3-swan-lake-linux-x64.deb https://dist.ballerina.io/downloads/2201.12.3/ballerina-2201.12.3-swan-lake-linux-x64.deb

# Install Ballerina
RUN dpkg -i /tmp/ballerina-2201.12.3-swan-lake-linux-x64.deb \
    && rm /tmp/ballerina-2201.12.3-swan-lake-linux-x64.deb

# Download and setup Java
RUN mkdir -p /opt/java \
    && curl -L -o /tmp/OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz" \
    && tar -xvzf /tmp/OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz -C /opt/java \
    && rm /tmp/OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz

# Set up environment variables for Java
ENV JAVA_HOME=/opt/java/jdk-21.0.5+11
ENV PATH=$JAVA_HOME/bin:$PATH

# Create a sample project with Ballerina
RUN mkdir -p /opt/project-template \
    && git clone https://github.com/gigara/ballerina-integrator-empty-proj.git /tmp/ballerina-integrator-empty-proj \
    && cp -r /tmp/ballerina-integrator-empty-proj/1.0.0/* /opt/project-template/ \
    && rm -rf /tmp/ballerina-integrator-empty-proj

# Expose the port the code server will run on
EXPOSE 8080

# Explicitly set the user to 10500
USER 10500

# Start the server
CMD ["./bin/code-server-devant", "--host", "0.0.0.0", "--port", "8080", "--default-folder", "/opt/project-template", "--connection-token", "giga"]
