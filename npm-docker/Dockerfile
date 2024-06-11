FROM ubuntu:20.04

ENV HOME=/home/node/app

RUN set -exo\
    && groupadd node\
    && useradd -g node --shell /bin/sh -d /home/node -m node\
    && apt-get update && apt-get install -y --no-install-recommends\
       ca-certificates=20230311ubuntu0.20.04.1\
       gnupg=2.2.19-3ubuntu2.2\
       curl=7.68.0-1ubuntu2.22\
       wget=1.20.3-1ubuntu1\
       nodejs=10.19.0~dfsg-3ubuntu1.6\
       npm=6.14.4+ds-1ubuntu2\
    && apt-get clean\
    && rm -rf /var/lib/apt/lists/*\
    && node -v\
    && npm -v

RUN mkdir -p $HOME && chown -R node:node $HOME
WORKDIR "$HOME"
USER node
COPY ./src/package.json $HOME
RUN npm install && npm cache clean --force
COPY --chown=node:node ./src/ .
ENTRYPOINT ["npm"]
CMD ["run", "prod"]
