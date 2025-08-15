FROM gigara/integration-web-editor:latest

# Ensure the Devant user has proper permissions
RUN groupadd -g 10500 chouser || true && \
	useradd -u 10500 -g 10500 -d /tmp/chouser -m chouser || true && \
	chown -R 10500:10500 /tmp/chouser

COPY .choreo/setup.sh /usr/local/bin/setup.sh

RUN sed -i 's/\r$//' /usr/local/bin/setup.sh && \
chmod +x /usr/local/bin/setup.sh && \
chown 10500:10500 /usr/local/bin/setup.sh

# set permissions for the extensions folder
RUN mkdir -p /home/chouser/.vscode-server-devant/extensions && \
	cp -r /root/.vscode-server-devant/extensions/. /home/chouser/.vscode-server-devant/extensions/

# Download all VSIX artifacts from the release with name "code-server-release" in the Ballerina VSCode repo and extract them
RUN set -eux; \
    GH_API="https://api.github.com/repos/wso2/ballerina-vscode/releases?per_page=50"; \
    RELEASE_ID=$(curl -s $GH_API | jq -r '.[] | select(.name == "code-server-release") | .id' | head -n1); \
    if [ -z "$RELEASE_ID" ]; then echo "Release 'code-server-release' not found!"; exit 0; fi; \
    ASSETS=$(curl -s "https://api.github.com/repos/wso2/ballerina-vscode/releases/$RELEASE_ID/assets"); \
    COUNT=$(echo "$ASSETS" | jq 'length'); \
    if [ "$COUNT" -eq 0 ]; then echo "No assets found in release!"; exit 0; fi; \
    mkdir -p /tmp/vsix; \
    for i in $(seq 0 $((COUNT-1))); do \
        NAME=$(echo "$ASSETS" | jq -r ".[$i].name"); \
        BASENAME="$(basename "$NAME" | rev | cut -d. -f2- | rev)"; \
        URL=$(echo "$ASSETS" | jq -r ".[$i].browser_download_url"); \
        if echo "$NAME" | grep -qE '\.vsix$'; then \
            echo "Downloading $NAME from $URL"; \
            curl -L -H "Accept: application/octet-stream" "$URL" -o "/tmp/vsix/$NAME"; \
            EXT_DIR="/home/chouser/.vscode-server-devant/extensions/${BASENAME%}"; \
            if [ -d "$EXT_DIR" ]; then rm -rf "$EXT_DIR"; fi; \
            mkdir -p "$EXT_DIR"; \
            unzip -q "/tmp/vsix/$NAME" -d /tmp/vsix/extract_tmp; \
            cp -r /tmp/vsix/extract_tmp/extension/. "$EXT_DIR/"; \
            rm -rf /tmp/vsix/extract_tmp; \
        fi; \
    done; \
    rm -rf /tmp/vsix

# Download & install Ballerina & Java
RUN curl -o /tmp/ballerina-2201.12.3-swan-lake-linux-x64.deb https://dist.ballerina.io/downloads/2201.12.3/ballerina-2201.12.3-swan-lake-linux-x64.deb && \
    dpkg -i /tmp/ballerina-2201.12.3-swan-lake-linux-x64.deb && \
    rm /tmp/ballerina-2201.12.3-swan-lake-linux-x64.deb

# update Bal
RUN bal dist update && bal dist use 2201.12.7

# install dependencies
RUN apt-get update && apt-get install -y \
	procps \
	lsof \
    nginx \
	&& rm -rf /var/lib/apt/lists/*

# Bal cache
RUN mkdir -p /root/bal
COPY .choreo/extension.bal /root/bal/extension.bal
RUN cd /root/bal && \
	bal build extension.bal && \
	rm -r /root/bal
RUN mkdir -p /home/chouser/.ballerina && \
	cp -r /root/.ballerina/. /home/chouser/.ballerina/

RUN chown -R 10500:10500 /home/chouser  && \
	chmod -R 777 /home/chouser

    # Set up nginx directories with proper permissions
RUN mkdir -p /tmp/client_temp /tmp/proxy_temp_path /tmp/fastcgi_temp /tmp/uwsgi_temp /tmp/scgi_temp && \
    touch /tmp/nginx.pid && \
    chown -R 10500:10500 /tmp && \
    chmod -R 777 /tmp && \
    chmod 666 /tmp/nginx.pid

# Copy nginx configuration files to the standard location
# They will be copied to /tmp at runtime
COPY .choreo/nginx.conf /etc/nginx/nginx.conf
COPY .choreo/mime.types /etc/nginx/mime.types

EXPOSE 8081
USER 10500

ENV HOME=/tmp/chouser
ENTRYPOINT ["/usr/local/bin/setup.sh"]
