FROM alpine:edge

RUN apk add libstdc++ libgcc gtk+3.0 alsa-lib dbus-glib libxt ttf-dejavu python3 xvfb xdotool ifupdown-ng openrc 7zip

RUN mkdir /browser
COPY palemoon.tar.xz /browser/palemoon.tar.xz
WORKDIR /browser
RUN tar xvf palemoon.tar.xz
RUN rm palemoon.tar.xz

RUN mkdir /browser_profile
WORKDIR /browser_profile
COPY MSVS.zip /browser_profile/
RUN unzip /browser_profile/MSVS.zip

RUN mkdir /scripts
WORKDIR /scripts
COPY src/MSVS.py /scripts/MSVS.py
COPY src/xvfbwrapper.py /scripts/xvfbwrapper.py
COPY src/init.sh /scripts/init.sh

RUN mkdir /www

RUN echo "* */12 * * * /usr/bin/python /scripts/MSVS.py >/dev/null 2>&1" >> /etc/crontab

COPY msvs /etc/init.d/msvs
RUN chmod +x /etc/init.d/msvs

RUN rc-update add msvs sysinit

ENTRYPOINT echo "Setup complete"
