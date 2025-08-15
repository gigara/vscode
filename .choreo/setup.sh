#!/bin/bash
set -e

mkdir -p /tmp/chouser
chmod -R 777 /tmp/chouser

# Create a writable log directory in /tmp for nginx
mkdir -p /tmp/nginx/logs
mkdir -p /tmp/nginx/conf
chmod -R 777 /tmp/nginx

# Copy nginx configuration files to the writable location
cp /etc/nginx/nginx.conf /tmp/nginx/conf/
cp /etc/nginx/mime.types /tmp/nginx/conf/

# Update the include path in the nginx.conf file to point to the new location
sed -i 's|include[[:space:]]*mime.types;|include /tmp/nginx/conf/mime.types;|g' /tmp/nginx/conf/nginx.conf

# Git clone logic based on environment variable
if [ -n "$GIT_CLONE_URL" ]; then
	echo "Cloning from custom URL: $GIT_CLONE_URL"
	git clone "$GIT_CLONE_URL" /tmp/bi-project
	cp -r /tmp/bi-project/. /tmp/chouser/project/
	rm -rf /tmp/bi-project
	mkdir -p /tmp/chouser/project/.vscode
	curl -sSL "https://raw.githubusercontent.com/gigara/ballerina-integrator-empty-proj/refs/heads/main/1.0.0/.vscode/settings.json" -o /tmp/chouser/project/.vscode/settings.json
	curl -sSL "https://raw.githubusercontent.com/gigara/ballerina-integrator-empty-proj/refs/heads/main/1.0.0/.vscode/launch.json" -o /tmp/chouser/project/.vscode/launch.json
else
    echo "Using default repository"
    git clone https://github.com/gigara/ballerina-integrator-empty-proj.git /tmp/bi-project
    cp -r /tmp/bi-project/1.0.0/. /tmp/chouser/project/
    rm -rf /tmp/bi-project
fi

bal dist use 2201.12.7

git config --global user.name "devant-cloud-editor"
git config --global user.email "devant-cloud-editor@wso2.com"

cp -r /home/chouser/. /tmp/chouser/

# Create symlink to mounted extension for live updates
if [ -d "/mnt/ballerina-extension" ]; then
	rm -rf /tmp/chouser/.vscode-server-devant/extensions/wso2.ballerina/*
    ln -sf /mnt/ballerina-extension/* /tmp/chouser/.vscode-server-devant/extensions/wso2.ballerina
fi
if [ -d "/mnt/bi-extension" ]; then
	rm -rf /tmp/chouser/.vscode-server-devant/extensions/wso2.ballerina-integrator/*
    ln -sf /mnt/bi-extension/* /tmp/chouser/.vscode-server-devant/extensions/wso2.ballerina-integrator
fi
if [ -d "/mnt/platform-extension" ]; then
	rm -rf /tmp/chouser/.vscode-server-devant/extensions/wso2.wso2-platform/*
    ln -sf /mnt/platform-extension/* /tmp/chouser/.vscode-server-devant/extensions/wso2.wso2-platform
fi

# Set up correct temp locations for nginx
touch /tmp/nginx.pid
chmod 666 /tmp/nginx.pid
CODE_SERVER_BIN="/usr/bin/code-server"
DEFAULT_WORKSPACE="/tmp/chouser/project/$GIT_SUB_PATH"
APP_NAME="Devant Editor"
PORT=8080

"$CODE_SERVER_BIN" \
  --app-name "$APP_NAME" \
  --builtin-extensions-dir /tmp/chouser/.vscode-server-devant/extensions/ \
  --user-data-dir /tmp/chouser/vscode-data \
  --disable-telemetry \
  --disable-workspace-trust \
  --disable-update-check \
  --bind-addr=0.0.0.0:$PORT \
  "${DEFAULT_WORKSPACE}" &

CODE_SERVER_PID=$!

# Give code-server a moment to start
sleep 3

# Check if code-server started successfully
if kill -0 $CODE_SERVER_PID 2>/dev/null; then
  echo "✅ code-server started successfully (PID: $CODE_SERVER_PID)"
else
  echo "❌ code-server failed to start"
  exit 1
fi

# Start Nginx in the foreground using our config from /tmp
echo "Starting Nginx for WebSocket proxying..."
exec nginx -c /tmp/nginx/conf/nginx.conf -g "daemon off;"
