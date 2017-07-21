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
ENV['FFMPEG_DIR'] ||= '.ffmpeg'

DIST_TARBALL = "dist-#{ENV['FFMPEG_VERSION']}.tar.xz"

task default: [:dist]

desc "Upload custom-build binaries to be accessible by FFmpeg Heroku buildpack."
task dist: [DIST_TARBALL] do |t|
  Aws::S3::Client.new.
      put_object bucket: ENV['FFMPEG_S3_BUCKET'],
                 key: "#{ENV['STACK']}/ffmpeg/#{ENV['FFMPEG_VERSION']}.tar.xz",
                 body: File.open(t.prerequisites.first)
end

file DIST_TARBALL => [ENV['FFMPEG_DIR']] do |t|
  excludes = %w[include share/man share/ffmpeg/examples lib/pkgconfig]
  exclude_args = excludes.map {|x| ['--exclude', x]}.flatten
  sh 'tar', '-cJf', t.name, '-C', t.prerequisites.first,
     *exclude_args, File.basename(t.prerequisites.first)
end
CLEAN << DIST_TARBALL
