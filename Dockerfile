FROM heroku/heroku:18-build

ENV BUILD_DIR="${BUILD_DIR:-/app}"
WORKDIR ${BUILD_DIR}

COPY FFmpeg.asc FFmpeg.asc
RUN ["gpg", "--import", "FFmpeg.asc"]
RUN ["rm", "FFmpeg.asc"]

RUN apt-get update && apt-get install -y yasm libmp3lame-dev

RUN ["gem", "install", "bundler", "-N"]
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN ["bundle"]

ENV FFMPEG_DIR="${BUILD_DIR}/.ffmpeg"
VOLUME ["${FFMPEG_DIR}.build"]

COPY Rakefile Rakefile
COPY rakelib rakelib
CMD ["bundle", "exec", "rake"]
