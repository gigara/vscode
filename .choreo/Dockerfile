FROM gigara/devant-editor

# Ensure the Devant user has proper permissions
RUN groupadd -g 10500 chouser || true && \
    useradd -u 10500 -g 10500 -d /home/chouser -m chouser || true && \
    chown -R 10500:10500 /home/chouser

COPY .choreo/setup.sh /usr/local/bin/setup.sh

# Ensure the setup script has correct line endings and is executable
RUN sed -i 's/\r$//' /usr/local/bin/setup.sh && \
chmod +x /usr/local/bin/setup.sh && \
chown 10500:10500 /usr/local/bin/setup.sh

# set permissions for the extensions folder
RUN mkdir -p /home/.vscode-server-devant/extensions && \
	cp -a /root/.vscode-server-devant/extensions/* /home/.vscode-server-devant/extensions/
RUN chown -R 10500:10500 /home/.vscode-server-devant/extensions/

EXPOSE 8081
USER 10500

WORKDIR /home/chouser/project

ENTRYPOINT ["/usr/local/bin/setup.sh"]
