FROM quay.io/redhatgov/workshop-dashboard:latest

USER root

COPY ./workshop /tmp/src/workshop

RUN rm -rf /tmp/src/.git* && \
    chown -R 1001 /tmp/src && \
    chgrp -R 0 /tmp/src && \
    chmod -R g+w /tmp/src

USER 1001

RUN /usr/libexec/s2i/assemble
EXPOSE 10080