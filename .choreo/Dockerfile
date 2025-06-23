FROM gigara/devant-editor

# Ensure the Devant user has proper permissions
RUN groupadd -g 10500 chouser || true && \
	useradd -u 10500 -g 10500 -d /tmp/chouser -m chouser || true && \
	chown -R 10500:10500 /tmp/chouser

COPY .choreo/setup.sh /usr/local/bin/setup.sh

# Ensure the setup script has correct line endings and is executable
RUN sed -i 's/\r$//' /usr/local/bin/setup.sh && \
chmod +x /usr/local/bin/setup.sh && \
chown 10500:10500 /usr/local/bin/setup.sh

# set permissions for the extensions folder
RUN mkdir -p /home/chouser/.vscode-server-devant/extensions && \
	cp -r /root/.vscode-server-devant/extensions/. /home/chouser/.vscode-server-devant/extensions/

# install dependencies
RUN apt-get update && apt-get install -y \
	procps \
	lsof \
	&& rm -rf /var/lib/apt/lists/*

# Bal cache
RUN mkdir -p /root/bal
COPY .choreo/extension.bal /root/bal/extension.bal
RUN cd /root/bal && \
	bal build extension.bal && \
	rm -r /root/bal
RUN mkdir -p /home/chouser/.ballerina && \
	cp -r /root/.ballerina/. /home/chouser/.ballerina/

RUN git clone https://github.com/gigara/ballerina-integrator-empty-proj.git /home/ballerina-integrator-empty-proj && \
	mkdir -p /home/chouser/project && \
	cp -r /home/ballerina-integrator-empty-proj/1.0.0/. /home/chouser/project/ && \
	rm -rf /home/ballerina-integrator-empty-proj

RUN chown -R 10500:10500 /home/chouser  && \
	chmod -R 777 /home/chouser
RUN sed -i 's/-Xms256m -Xmx2048m \\/-Xms256m -Xmx512m \\/g' /usr/lib/ballerina/distributions/ballerina-2201.12.3/bin/bal

EXPOSE 8081
USER 10500

ENTRYPOINT ["/usr/local/bin/setup.sh"]
