FROM rustlang/rust:nightly-buster AS builder

WORKDIR /root/shadowsocks-rust

ADD . .

RUN cargo build --release --bin sslocal

RUN cargo build --release --bin ssserver

FROM alpine:3.7

COPY --from=builder /root/shadowsocks-rust/target/release/sslocal /usr/bin

COPY --from=builder /root/shadowsocks-rust/target/release/ssserver /usr/bin

# TODO Choose to run ssserver or sslocal