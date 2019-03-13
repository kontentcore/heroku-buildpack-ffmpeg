# Heroku Buildpack with FFmpeg

Practically all FFmpeg buildpacks we have found simply contain static binaries in their repository and not much else. This is an issue regarding maintainability and security. This is why this buildpack exists. It provides a way from official FFmpeg source code to binaries accessible via `PATH` environment variable in Heroku slug running your application.

You might ask why not to use some Heroku Add-on or other third-party service like typical Heroku user? We think they are expensive, slow or limited for what we need.

## Usage

Add buildpack to your existing app:

    heroku buildpacks:add https://github.com/kontentcore/heroku-buildpack-ffmpeg

If you want to see changes immediately, create an empty commit:

    git commit --allow-empty -m 'Add FFmpeg buildpack'

See for yourself:

    git push heroku master
    # …
    heroku run ffmpeg -version
    # Running ffmpeg -version on ⬢ kc-ffmpeg... up, run.2925 (Hobby)
    # ffmpeg version 4.1.1 Copyright (c) 2000-2019 the FFmpeg developers
    # built with gcc 7 (Ubuntu 7.3.0-27ubuntu1~18.04)
    # configuration: --prefix=/app/.ffmpeg --enable-nonfree --enable-gnutls
    # libavutil      56. 22.100 / 56. 22.100
    # libavcodec     58. 35.100 / 58. 35.100
    # libavformat    58. 20.100 / 58. 20.100
    # libavdevice    58.  5.100 / 58.  5.100
    # libavfilter     7. 40.101 /  7. 40.101
    # libswscale      5.  3.100 /  5.  3.100
    # libswresample   3.  3.100 /  3.  3.100

As you can `ffmpeg` and other FFmpeg binaries are accessible via `PATH` environment variable.

## Behind the Scenes

We utilize only `bin/compile` script expected by [Heroku Buildpack API](https://devcenter.heroku.com/articles/buildpack-api). In this phase we download pre-build binaries from AWS S3 for specified FFmpeg version and Heroku stack. Building FFmpeg from sources during this phase is something that would be great but it is not implemented.

[Heroku stack](https://devcenter.heroku.com/articles/stack) your app is running on is something you have to configure yourself.

Desired FFmpeg version cat be set by `FFMPEG_VERSION` config var. It defaults to whatever we have seen as the last stable version which is *4.1.1* as of this writing.

The AWS S3 bucket can be overridden by setting `FFMPEG_S3_BUCKET` config var. It defaults to `kc-heroku-buildpack-binaries`. We expect to find binary archives with these keys: `ffmpeg/$STACK/$FFMPEG_VERSION.tar.xz`.

## Building Binary Archives

We use Docker with Heroku-18 build image. It is simple and straightforward.

The code itself should build FFmpeg on Cedar-14 but it requires more complicated setup. We have no need for it, so we do not support it.

Run the following to build and publish binary archive:

    docker build -t heroku-buildpack-ffmpeg .
    docker run \
      -e "AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)"
      -e "AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)" \
      heroku-buildpack-ffmpeg

We use [AWS CLI](https://aws.amazon.com/cli/) in the example above, but you can use anything that suits you. However, `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are required. There are other environment variables which affect the build process and were described before:

* `FFMPEG_S3_BUCKET`
* `FFMPEG_VERSION`
