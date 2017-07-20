# frozen_string_literal: true
require 'uri'
require 'net/http'

module FFmpeg
  extend Rake::DSL

  DOWNLOADS_BASE_URL = 'http://ffmpeg.org/releases'
  VERSION = ENV['FFMPEG_VERSION']
  TARBALL_EXT = '.tar.xz'
  DOWNLOADS_DIR = 'downloads'
  PREFIX = ENV['FFMPEG_DIR']

  BASE_NAME = "ffmpeg-#{VERSION}"
  SRC_DIR = BASE_NAME
  BUILD_DIR = "#{BASE_NAME}.build"

  directory PREFIX
  file PREFIX => ["#{BUILD_DIR}/Makefile"] do |t|
    Dir.chdir File.dirname t.prerequisites.first do
      sh 'make', 'install'
    end
  end
  CLEAN << PREFIX

  file "#{BUILD_DIR}/Makefile" => ["#{SRC_DIR}/configure", BUILD_DIR, '.yasm'] do |t|
    configure = File.absolute_path t.prerequisites.first
    prefix = File.absolute_path PREFIX
    yasm = File.absolute_path '.yasm/bin/yasm'
    Dir.chdir File.dirname t.name do
      sh configure, "--prefix=#{prefix}", "--yasmexe=#{yasm}"
    end
  end

  directory BUILD_DIR
  CLEAN << BUILD_DIR

  file "#{SRC_DIR}/configure" => [
      "#{DOWNLOADS_DIR}/#{BASE_NAME}#{TARBALL_EXT}.asc",
      "#{DOWNLOADS_DIR}/#{BASE_NAME}#{TARBALL_EXT}"
  ] do |t|
    sh 'gpg', '--verify', *t.prerequisites
    sh 'tar', '-xJf', t.prerequisites.last
  end
  CLOBBER << SRC_DIR

  file "#{DOWNLOADS_DIR}/#{BASE_NAME}#{TARBALL_EXT}" => [DOWNLOADS_DIR] do |t|
    uri = URI "#{DOWNLOADS_BASE_URL}/#{File.basename t.name}"
    rake_output_message "Download #{uri} to #{t.name}"
    File.write t.name, Net::HTTP.get(uri)
  end
  CLOBBER << "#{DOWNLOADS_DIR}/#{BASE_NAME}#{TARBALL_EXT}"

  file "#{DOWNLOADS_DIR}/#{BASE_NAME}#{TARBALL_EXT}.asc" => [DOWNLOADS_DIR] do |t|
    uri = URI "#{DOWNLOADS_BASE_URL}/#{File.basename t.name}"
    rake_output_message "Download #{uri} to #{t.name}"
    File.write t.name, Net::HTTP.get(uri)
  end
  CLOBBER << "#{DOWNLOADS_DIR}/#{BASE_NAME}#{TARBALL_EXT}.asc"

  directory DOWNLOADS_DIR
  CLOBBER << DOWNLOADS_DIR
end
