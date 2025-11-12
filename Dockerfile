# A Dockerfile to make development setup easier. Run with:
# docker run -it --rm -e OPENAI_API_KEY=$OPENAI_API_KEY $(docker build -q .)

FROM ubuntu

RUN apt update \
    && DEBIAN_FRONTEND=noninteractive apt install -y tzdata \
    && apt install -y python3 python3-pip \
    && apt install -y locales \
    && apt install -y git \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# UTF-8.
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# ChatDBG.
COPY . /root/ChatDBG
RUN pip install --break-system-packages -e /root/ChatDBG
ENV CHATDBG_UNSAFE=1

ENV TERM=xterm-256color
WORKDIR /root/ChatDBG
