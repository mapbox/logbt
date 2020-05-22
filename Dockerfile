FROM ubuntu:18.04

# docker build -t logbt -f Dockerfile .
# docker run --privileged logbt

ENV WORKINGDIR /usr/local/src
WORKDIR ${WORKINGDIR}
COPY bin/logbt bin/logbt
COPY test test
ADD .nvmrc ./
RUN apt-get update -y && \
 apt-get install -y bash curl gdb git-core g++ ca-certificates --no-install-recommends

RUN NODE_SLUG=node-v$(cat .nvmrc)-linux-x64 && \
 curl -sL --retry 3 -O https://nodejs.org/dist/v$(cat .nvmrc)/$NODE_SLUG.tar.gz && \
 tar xzf $NODE_SLUG.tar.gz --strip-components=1 -C /usr/local  && \
 rm $NODE_SLUG.tar.gz

CMD ./bin/logbt --setup && \
    ./bin/logbt --test && \
    ./test/unit.sh