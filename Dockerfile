FROM heroku/heroku:16-build

ENV BUILD_DIR="${BUILD_DIR:-/app}"
WORKDIR ${BUILD_DIR}

COPY FFmpeg.asc FFmpeg.asc
RUN ["gpg", "--no-use-agent", "--import", "FFmpeg.asc"]
RUN ["rm", "FFmpeg.asc"]

RUN ["gem", "install", "bundler", "-N"]
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN ["bundle"]

ENV FFMPEG_DIR="${BUILD_DIR}/.ffmpeg"
VOLUME ["${FFMPEG_DIR}.build"]

COPY Rakefile Rakefile
COPY rakelib rakelib
CMD ["bundle", "exec", "rake"]
