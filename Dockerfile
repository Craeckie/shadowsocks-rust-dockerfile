FROM rust:alpine AS builder
#ENV V2RAY_DOWNLOAD_URL https://github.com/shadowsocks/v2ray-plugin/releases/download/v1.3.1/v2ray-plugin-linux-amd64-v1.3.1.tar.gz

WORKDIR /builds

RUN apk add --virtual .build build-base git go curl && \
    toolchain="`curl -L "https://github.com/shadowsocks/shadowsocks-rust/raw/master/rust-toolchain"`" && \
    rustup default "$toolchain" && \
    cargo install --features "dns-over-tls,dns-over-https,trust-dns,aead-cipher-extra" shadowsocks-rust --root . && \
    git clone https://github.com/Craeckie/v2ray-plugin.git && \
    cd v2ray-plugin && go build && cd .. && \
    # && mv v2ray-plugin /usr/bin/ && cd .. && \
    apk del .build
    # curl -L "${V2RAY_DOWNLOAD_URL}" | tar -xvf - v2ray-plugin_linux_amd64 && \
    # mv v2ray-plugin_linux_amd64 /usr/bin/v2ray-plugin

FROM alpine

COPY --from=builder /builds/bin/ssserver /usr/bin/
COPY --from=builder /builds/v2ray-plugin/v2ray-plugin /usr/bin/

CMD [ "/usr/bin/ssserver", "-c", "/server.json"]
