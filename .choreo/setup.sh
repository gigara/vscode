#!/bin/bash
set -e

mkdir -p /tmp/chouser
chmod -R 777 /tmp/chouser

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

WORKDIR /tmp/chouser/project/$GIT_SUB_PATH

exec dumb-init /usr/bin/code-server --bind-addr 0.0.0.0:8080 --app-name "Devant Editor" --PASSWORD $CONNECTION_TOKEN --disable-workspace-trust --builtin-extensions-dir /tmp/chouser/.vscode-server-devant/extensions/ --user-data-dir /tmp/chouser/vscode-data /tmp/chouser/project/$GIT_SUB_PATH
