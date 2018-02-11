ARG DOCKER_SEMVER=18.02.0
FROM docker:${DOCKER_SEMVER}-ce
RUN \
    apk add --no-cache coreutils && \
        apk add --no-cache sudo && \
        apk add --no-cache util-linux && \
        adduser -D user && \
        echo "user ALL=(ALL) NOPASSWD:SETENV: /usr/local/bin/docker" > /etc/sudoers.d/user && \
        chmod 0444 /etc/sudoers.d/user && \
        rm -rf /var/cache/apk/*
USER user
VOLUME /home
WORKDIR /home/user
COPY entrypoint.sh /home/user/
ENV DOCKER_SEMVER=18.02.0
ENV MIDDLE_SEMVER=0.0.2
ENV CLOUD9_PORT=10604
ENV BROWSER_SEMVER=0.0.0
ENV INNER_SEMVER=0.0.5
ENTRYPOINT ["sh", "/home/user/entrypoint.sh"]
CMD []