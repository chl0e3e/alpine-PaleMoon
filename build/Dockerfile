FROM alpine:edge

RUN apk add libstdc++ libgcc gtk+3.0 alsa-lib dbus-glib libxt

RUN mkdir /browser
COPY palemoon-32.5.0a1.linux-x86_64-gtk3.tar.xz /browser/palemoon.tar.xz
WORKDIR /browser
RUN tar xvf palemoon.tar.xz
RUN rm palemoon.tar.xz

ENTRYPOINT LD_LIBRARY_PATH="/browser/palemoon" /browser/palemoon/palemoon
