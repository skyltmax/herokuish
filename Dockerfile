FROM heroku/heroku:18

ENV DEBIAN_FRONTEND noninteractive

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
