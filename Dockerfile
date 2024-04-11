FROM ubuntu:jammy as builder
RUN apt update && apt install -y curl build-essential debhelper devscripts pkg-config zip
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN mkdir /build
COPY src /build/src
COPY libs /build/libs
COPY Cargo.toml /build/Cargo.toml
COPY Cargo.lock /build/Cargo.lock
COPY build.rs /build/build.rs
COPY db_v2.sqlite3 /build/db_v2.sqlite3
RUN . /root/.cargo/env && cd /build && DATABASE_URL=sqlite://./db_v2.sqlite3 cargo build --release
RUN mkdir -p /build/ubuntu-jammy/bin \
    && cp /build/target/release/hbbr /build/ubuntu-jammy/bin/ \
    && cp /build/target/release/hbbs /build/ubuntu-jammy/bin/ \
    && cp /build/target/release/rustdesk-utils /build/ubuntu-jammy/bin/
COPY systemd /build/ubuntu-jammy/systemd
COPY debian /build/ubuntu-jammy/debian
RUN cd /build/ubuntu-jammy \
    && cat debian/control.tpl | sed "s/{{ ARCH }}/$(dpkg --print-architecture)/" > debian/control \
    && rm debian/control.tpl \
    && debuild -i -us -uc -b -a$(dpkg --print-architecture)

FROM ubuntu:jammy
RUN mkdir -p /usr/local/share/debpackages
COPY --from=builder /build/*.deb /usr/local/share/debpackages
COPY --from=builder /build/target/release/hbbs /usr/local/bin/hbbs
COPY --from=builder /build/target/release/hbbr /usr/local/bin/hbbr
COPY --from=builder /build/target/release/rustdesk-utils /usr/local/bin/rustdesk-utils
