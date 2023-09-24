# Python building stage
FROM alpine:3.14 as python-builder
RUN apk add --no-cache \
    tar xz gcc g++ make linux-headers libffi-dev openssl-dev \
    zlib-dev ncurses-dev bzip2-dev xz-dev readline-dev sqlite-dev \
    libxml2-dev libxslt-dev

WORKDIR /tmp
RUN --mount=type=cache,target=/tmp/build-cache \
    wget https://www.python.org/ftp/python/3.10.0/Python-3.10.0.tar.xz && \
    tar -xf Python-3.10.0.tar.xz && \
    cd Python-3.10.0 && \
    ./configure --prefix=/usr/local && \
    make -j $(nproc) && \
    make install

FROM jrottenberg/ffmpeg:6-alpine AS builder

COPY --from=python-builder /usr/local /usr/local/

RUN apk add --no-cache git bash zsh vim curl wget make yarn py3-pip && rm -rf /var/cache/apk/* /tmp/*

# Use cache for pip installs
RUN --mount=type=cache,target=/root/.cache/pip \
    pip3 install --upgrade pip setuptools supervisor && \
    pip3 install --ignore-installed distlib pipenv

RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.1/zsh-in-docker.sh)" -- \
    -p git -p ssh-agent -p https://github.com/zsh-users/zsh-autosuggestions -p https://github.com/zsh-users/zsh-completions

COPY supervisord.conf /etc/supervisord.conf
COPY zsh/.p10k.zsh /root/.p10k.zsh
COPY zsh/.zshrc /root/.zshrc

FROM builder as app

RUN mkdir -p /var/www/app

WORKDIR /var/www/app

ENV SHA=833c782daee916f1003c59f0d5d3a69a1ea27119
RUN --mount=type=cache,target=/root/.cache/pip \
    git clone https://github.com/solitus0/encoder_worker.git . && \
    git reset --hard $SHA && \
    pipenv --python /usr/local/bin/python3 install .

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
