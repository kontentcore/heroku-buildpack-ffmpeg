# frozen_string_literal: true
require 'uri'
require 'net/http'

module Yasm
  extend Rake::DSL

  DOWNLOADS_BASE_URL = 'http://www.tortall.net/projects/yasm/releases'
  VERSION = '1.3.0'
  TARBALL_EXT = '.tar.gz'
  PREFIX = '.yasm'

  BASE_NAME = "yasm-#{VERSION}"
  SRC_TARBALL = "#{FFMPEG_BUILD_DIR}/#{BASE_NAME}#{TARBALL_EXT}"
  SRC_DIR = "#{FFMPEG_BUILD_DIR}/#{BASE_NAME}"
  BUILD_DIR = "#{FFMPEG_BUILD_DIR}/#{ENV['STACK']}/#{BASE_NAME}"

  directory PREFIX
  file PREFIX => ["#{BUILD_DIR}/Makefile"] do |t|
    Dir.chdir File.dirname t.prerequisites.first do
      sh 'make', 'install'
    end
  end
  CLEAN << PREFIX

  file "#{BUILD_DIR}/Makefile" => ["#{SRC_DIR}/configure", BUILD_DIR] do |t|
    configure = File.absolute_path t.prerequisites.first
    prefix = File.absolute_path PREFIX
    Dir.chdir File.dirname t.name do
      sh configure, "--prefix=#{prefix}"
    end
  end

  directory BUILD_DIR
  CLEAN << BUILD_DIR

  file "#{SRC_DIR}/configure" => [SRC_TARBALL] do |t|
    sh 'tar', '-xzf', t.prerequisites.first,
       '-C', File.dirname(File.dirname(t.name))
  end
  CLOBBER << SRC_DIR

  file SRC_TARBALL do |t|
    uri = URI "#{DOWNLOADS_BASE_URL}/#{File.basename t.name}"
    rake_output_message "Download #{uri} to #{t.name}"
    File.write t.name, Net::HTTP.get(uri)
  end
  CLOBBER << SRC_TARBALL
end
