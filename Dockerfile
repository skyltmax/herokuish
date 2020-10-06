FROM heroku/heroku:18

ENV DEBIAN_FRONTEND noninteractive

# libspng
ENV SPNG_VERSION 0.6.1

RUN apt-get update -qq && apt-get install -y python3 python3-pip python3-setuptools ninja-build \
	&& pip3 install meson \
  && curl -fsSLO --compressed "https://github.com/randy408/libspng/archive/v$SPNG_VERSION.tar.gz" \
  && tar -xzf "v$SPNG_VERSION.tar.gz" --no-same-owner \
  && rm "v$SPNG_VERSION.tar.gz" \
  && cd "libspng-$SPNG_VERSION" \
  && meson build --buildtype=release \
  && cd build \
  && ninja \
  && ninja install \
  && cd / \
  && rm -r "libspng-$SPNG_VERSION"

# Vips
ENV VIPS_VERSION 8.10.1

RUN apt-get install -y --no-install-recommends glib2.0-dev expat gobject-introspection libjpeg-dev libexif-dev \
  libgif-dev librsvg2-dev libpoppler-glib-dev libtiff-dev fftw3-dev liblcms2-dev libpng-dev poppler-utils \
  libpango1.0-dev liborc-0.4-dev libwebp-dev libmagickwand-dev \
  && curl -fsSLO --compressed "https://github.com/libvips/libvips/releases/download/v$VIPS_VERSION/vips-$VIPS_VERSION.tar.gz" \
  && tar -xzf "vips-$VIPS_VERSION.tar.gz" --no-same-owner \
  && rm "vips-$VIPS_VERSION.tar.gz" \
  && cd "vips-$VIPS_VERSION" \
  && ./configure \
  && make \
  && make install \
  && ldconfig \
  && cd / \
  && rm -r "vips-$VIPS_VERSION"

RUN apt-get update -qq \
 && apt-get install -qq -y daemontools gdb webp \
 && apt-get clean \
 && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /var/tmp/*
COPY ./build/linux/herokuish /bin/herokuish
RUN ln -s /bin/herokuish /build \
	&& ln -s /bin/herokuish /start \
	&& ln -s /bin/herokuish /exec
COPY include/default_user.bash /tmp/default_user.bash
RUN bash /tmp/default_user.bash && rm -f /tmp/default_user.bash
