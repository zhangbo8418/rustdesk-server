FROM sctg/sctgdesk-server-integration:latest as builder

FROM ubuntu:jammy
RUN mkdir -p /usr/local/bin
COPY --from=builder /usr/local/bin/hbbs /usr/local/bin/hbbs
COPY --from=builder /usr/local/bin/hbbr /usr/local/bin/hbbr
COPY --from=builder /usr/local/bin/rustdesk-utils /usr/local/bin/rustdesk-utils