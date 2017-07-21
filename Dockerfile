FROM heroku/heroku:16-build
RUN ["gem", "install", "bundler", "-N"]
RUN ["mkdir", "-p", "/app"]
WORKDIR /app
COPY FFmpeg.asc FFmpeg.asc
RUN ["gpg", "--no-use-agent", "--import", "FFmpeg.asc"]
RUN ["rm", "FFmpeg.asc"]
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN ["bundle"]
COPY Rakefile Rakefile
COPY rakelib rakelib
CMD ["bundle", "exec", "rake"]
