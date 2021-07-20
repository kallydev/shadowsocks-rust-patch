FROM --platform=$BUILDPLATFORM rust:1.53.0-buster AS build

ARG TARGETARCH

RUN apt-get update && apt-get install -y build-essential curl musl-tools

WORKDIR /root/shadowsocks-rust

ADD . .

RUN rustup install "$(cat rust-toolchain)"

RUN chmod +x build/build-docker && build/build-docker

FROM alpine:3.14 AS sslocal

COPY --from=build /root/shadowsocks-rust/target/release/sslocal /usr/bin

COPY --from=build /root/shadowsocks-rust/examples/config_docker.json /etc/shadowsocks-rust/config.json

ENTRYPOINT [ "sslocal", "--log-without-time", "-c", "/etc/shadowsocks-rust/config.json" ]

FROM alpine:3.14 AS ssserver

COPY --from=build /root/shadowsocks-rust/target/release/ssserver /usr/bin

COPY --from=build /root/shadowsocks-rust/examples/config_docker.json /etc/shadowsocks-rust/config.json

ENTRYPOINT [ "ssserver", "--log-without-time", "-c", "/etc/shadowsocks-rust/config.json" ]
