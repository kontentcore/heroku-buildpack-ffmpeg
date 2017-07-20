FROM heroku/heroku:16-build
RUN ["gem", "install", "bundler", "-N"]
RUN ["mkdir", "-p", "/app"]
WORKDIR /app
COPY FFmpeg.asc /app/FFmpeg.asc
RUN ["gpg", "--no-use-agent", "--import", "FFmpeg.asc"]
RUN ["rm", "FFmpeg.asc"]
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN ["bundle"]
COPY Rakefile /app/Rakefile
COPY rakelib /app/rakelib
CMD ["bundle", "exec", "rake"]
