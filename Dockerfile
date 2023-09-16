FROM alpine:edge

RUN apk add dumb-init musl libc6-compat linux-headers build-base bash git ca-certificates tzdata bzip2-dev coreutils dpkg-dev dpkg expat-dev findutils gcc g++ gdbm-dev libc-dev libffi-dev libnsl-dev libtirpc-dev linux-headers make ncurses-dev openssl-dev pax-utils readline-dev sqlite-dev tcl-dev tk tk-dev util-linux-dev xz-dev zlib-dev git

RUN mkdir /workspace
WORKDIR /workspace

COPY openssl-1.1.1v-r0.apk /workspace/openssl-1.1.1v-r0.apk
COPY openssl-dev-1.1.1v-r0.apk /workspace/openssl-dev-1.1.1v-r0.apk
COPY libssl1.1-1.1.1v-r0.apk /workspace/libssl1.1-1.1.1v-r0.apk
COPY libcrypto1.1-1.1.1v-r0.apk /workspace/libcrypto1.1-1.1.1v-r0.apk

RUN apk add openssl-1.1.1v-r0.apk openssl-dev-1.1.1v-r0.apk libssl1.1-1.1.1v-r0.apk libcrypto1.1-1.1.1v-r0.apk

COPY Python-2.7.18.tgz /workspace/Python-2.7.18.tgz
RUN tar xvf Python-2.7.18.tgz

WORKDIR /workspace/Python-2.7.18

RUN ./configure --enable-shared --with-system-expat --with-system-ffi --without-ensurepip --enable-optimizations
RUN make -j4
RUN make install

WORKDIR /workspace

COPY dbus-python-1.2.18.tar.gz /workspace/dbus-python-1.2.18.tar.gz

RUN tar xvf dbus-python-1.2.18.tar.gz

WORKDIR /workspace/dbus-python-1.2.18

RUN apk add dbus-dev glib-dev
RUN ./configure PYTHON_CPPFLAGS="-I/usr/local/include/python2.7" PYTHON_LIBS="-L/usr/local/lib/python2.7 -lpython2.7"
RUN make -j4
RUN make install

WORKDIR /workspace

COPY autoconf2.13-2.13-r1.apk /workspace/autoconf2.13-2.13-r1.apk
COPY gconf-3.2.6-r5.apk /workspace/gconf-3.2.6-r5.apk
COPY gconf-dev-3.2.6-r5.apk /workspace/gconf-dev-3.2.6-r5.apk
RUN apk add autoconf2.13-2.13-r1.apk gconf-dev-3.2.6-r5.apk gconf-3.2.6-r5.apk gtk+3.0 gtk+3.0-dev gtk+2.0 gtk+2.0-dev dbus-glib desktop-file-utils libxt alsa-lib startup-notification unzip zip yasm libpulse gcc alsa-lib-dev pulseaudio-dev libxt-dev

RUN git clone --recursive https://repo.palemoon.org/MoonchildProductions/Pale-Moon.git

WORKDIR /workspace/Pale-Moon/
COPY mozconfig /workspace/Pale-Moon/.mozconfig
RUN echo "#define caddr_t void*" >> platform/python/psutil/psutil/_psutil_linux.h
RUN sed -i "s/else:/else:\n    DEFINES['off64_t'] = 'off_t'/" platform/media/libstagefright/moz.build
RUN sed -i "s/PTHREAD_MUTEX_ADAPTIVE_NP/PTHREAD_MUTEX_DEFAULT/" platform/memory/mozjemalloc/jemalloc.c
RUN sed -i "s/PTHREAD_MUTEX_ADAPTIVE_NP/PTHREAD_MUTEX_DEFAULT/" platform/nsprpub/pr/src/pthreads/ptsynch.c
RUN sed -i "s/PTHREAD_ADAPTIVE_MUTEX_INITIALIZER_NP/PTHREAD_MUTEX_INITIALIZER/" platform/memory/mozjemalloc/jemalloc.c
RUN sed -i ':a;N;$!ba;s/#define NEG_USR32 NEG_USR32\n//' platform/media/ffvpx/libavcodec/x86/mathops.h
RUN sed -i ':a;N;$!ba;s/#define NEG_SSR32 NEG_SSR32\n//' platform/media/ffvpx/libavcodec/x86/mathops.h

RUN ./mach build
RUN ./mach package

ENTRYPOINT ls /workspace/Pale-Moon/obj-x86_64-pc-linux-gnu/dist/*.json
