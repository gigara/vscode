FROM gigara/devant-editor

# Ensure the Devant user has proper permissions
RUN groupadd -g 10500 chouser || true && \
    useradd -u 10500 -g 10500 -d /home/abc -m chouser || true && \
    chown -R 10500:10500 /root/.vscode-server-devant/ /opt/project-template/

EXPOSE 8081

USER 10500
