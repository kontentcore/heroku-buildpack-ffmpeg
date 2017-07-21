# frozen_string_literal: true
require 'rake/clean'
require 'aws-sdk'

ENV['STACK'] ||= case `lsb_release -irs`.chomp.split
                   when ['Ubuntu', '14.04'] then 'cedar-14'
                   when ['Ubuntu', '16.04'] then 'heroku-16'
                   else abort 'Cannot recognize Heroku Stack'
                 end
ENV['AWS_REGION'] ||= 'us-east-1'
ENV['FFMPEG_S3_BUCKET'] ||= 'kc-heroku-buildpack-binaries'
ENV['FFMPEG_VERSION'] ||= '3.3.2'

abort 'Config var FFMPEG_DIR must be set.' unless ENV['FFMPEG_DIR']

FFMPEG_BUILD_DIR = "#{ENV['FFMPEG_DIR']}.build"
FFMPEG_TARBALL = "#{FFMPEG_BUILD_DIR}/#{ENV['STACK']}/#{ENV['FFMPEG_VERSION']}.tar.xz"

task default: [:dist]

desc "Upload custom-build binaries to be accessible by FFmpeg Heroku buildpack."
task dist: [FFMPEG_TARBALL] do |t|
  key = "ffmpeg/#{ENV['STACK']}/#{ENV['FFMPEG_VERSION']}.tar.xz"
  rake_output_message "Upload FFmpeg binaries to s3://#{ENV['FFMPEG_S3_BUCKET']}/#{key}"
  Aws::S3::Client.new.
      put_object bucket: ENV['FFMPEG_S3_BUCKET'],
                 key: key,
                 body: File.open(t.prerequisites.first),
                 acl: 'public-read'
end

file FFMPEG_TARBALL => [ENV['FFMPEG_DIR'], FFMPEG_BUILD_DIR] do |t|
  excludes = %w[include share/man share/ffmpeg/examples lib/pkgconfig]
  exclude_args = excludes.map {|x| ['--exclude', x]}.flatten
  sh 'tar', '-cJf', t.name, '-C', t.prerequisites.first,
     *exclude_args, '.'
end
CLEAN << FFMPEG_TARBALL

directory File.dirname(FFMPEG_TARBALL)
CLOBBER << File.dirname(FFMPEG_TARBALL)
