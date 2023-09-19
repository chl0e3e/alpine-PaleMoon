FROM alpine:edge

RUN apk add libstdc++ libgcc gtk+3.0 alsa-lib dbus-glib libxt ttf-dejavu

RUN mkdir /browser
COPY  /browser/palemoon.tar.xz
WORKDIR /browser
RUN tar xvf palemoon.tar.xz
RUN rm palemoon.tar.xz

ENTRYPOINT LD_LIBRARY_PATH="/browser/palemoon" /browser/palemoon/palemoon
