FROM debian:latest

RUN apt-get update -y && apt-get install -y make socat openssl curl xxd --no-install-recommends
RUN groupadd --gid 999 shittr 
RUN useradd -m -s /bin/bash -u 999 -g shittr shittr
RUN mkdir /service && chown -R 999:999 /service

WORKDIR /service
USER shittr

CMD ["bash", "-c", "cd ro && make run6"]
