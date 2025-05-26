#!/bin/bash
set -e

# Clone template project to workspace
mkdir -p /home/chouser/project \
    && git clone https://github.com/gigara/ballerina-integrator-empty-proj.git /tmp/ballerina-integrator-empty-proj \
    && cp -a /tmp/ballerina-integrator-empty-proj/1.0.0/. /home/chouser/project/ \
    && rm -rf /tmp/ballerina-integrator-empty-proj

# Set up extensions directory symlink for the user
mkdir -p /home/chouser/.vscode-server-devant/extensions
cp -a /home/.vscode-server-devant/extensions/* /home/chouser/.vscode-server-devant/extensions/

exec /app/bin/code-server-devant --host 0.0.0.0 --port 8081 --default-folder /home/chouser/project --connection-token giga --disable-workspace-trust --extensions-dir /home/chouser/.vscode-server-devant/extensions/ --user-data-dir /tmp/vscode-data
