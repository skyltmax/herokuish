FROM heroku/heroku:20

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qq && apt-get install -y build-essential zlib1g-dev libpq-dev cmake pkg-config libssh-dev \
  libpthread-stubs0-dev python make g++

# libspng
# ENV SPNG_VERSION 0.6.1

# RUN apt-get update -qq && apt-get install -y python3 python3-pip python3-setuptools ninja-build \
# 	&& pip3 install meson \
#   && curl -fsSLO --compressed "https://github.com/randy408/libspng/archive/v$SPNG_VERSION.tar.gz" \
#   && tar -xzf "v$SPNG_VERSION.tar.gz" --no-same-owner \
#   && rm "v$SPNG_VERSION.tar.gz" \
#   && cd "libspng-$SPNG_VERSION" \
#   && meson build --buildtype=release \
#   && cd build \
#   && ninja \
#   && ninja install \
#   && cd / \
#   && rm -r "libspng-$SPNG_VERSION"

# Vips
ENV VIPS_VERSION 8.10.2

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

RUN echo '<policymap> \
  <!-- <policy domain="resource" name="temporary-path" value="/tmp"/> --> \
  <!-- <policy domain="resource" name="memory" value="2GiB"/> --> \
  <!-- <policy domain="resource" name="map" value="4GiB"/> --> \
  <!-- <policy domain="resource" name="area" value="1GB"/> --> \
  <!-- <policy domain="resource" name="disk" value="16EB"/> --> \
  <!-- <policy domain="resource" name="file" value="768"/> --> \
  <!-- <policy domain="resource" name="thread" value="4"/> --> \
  <!-- <policy domain="resource" name="throttle" value="0"/> --> \
  <!-- <policy domain="resource" name="time" value="3600"/> --> \
  <!-- <policy domain="system" name="precision" value="6"/> --> \
  <policy domain="cache" name="shared-secret" value="passphrase"/> \
  <policy domain="coder" rights="none" pattern="EPHEMERAL" /> \
  <policy domain="coder" rights="none" pattern="URL" /> \
  <policy domain="coder" rights="none" pattern="HTTPS" /> \
  <policy domain="coder" rights="none" pattern="MVG" /> \
  <policy domain="coder" rights="none" pattern="MSL" /> \
  <policy domain="coder" rights="none" pattern="TEXT" /> \
  <policy domain="coder" rights="none" pattern="SHOW" /> \
  <policy domain="coder" rights="none" pattern="WIN" /> \
  <policy domain="coder" rights="none" pattern="PLT" /> \
  <policy domain="path" rights="none" pattern="@*" /> \
</policymap>' \
> /etc/ImageMagick-6/policy.xml

# Chrome
ENV CHROME_VERSION 86
ENV CHROME_HEADLESS true

RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update \
	&& apt-get install -y --no-install-recommends google-chrome-stable=86.\*

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
