#!/bin/bash
set -e

mkdir -p /tmp/chouser
chmod -R 777 /tmp/chouser

cp -r /home/chouser/. /tmp/chouser/

exec /app/bin/code-server-devant --host 0.0.0.0 --port 8081 --default-folder /tmp/chouser/project --connection-token giga --disable-workspace-trust --extensions-dir /tmp/chouser/.vscode-server-devant/extensions/ --user-data-dir /tmp/chouser/vscode-data
