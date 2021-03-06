# frozen_string_literal: true

require 'active_support/core_ext/numeric/bytes'
require 'active_support/core_ext/enumerable'
require 'active_support/core_ext/string'

require 'http'
require 'net/sftp'

require 'sinatra'
require 'sinatra/streaming'

class Application < Sinatra::Base
  CHUNK_SIZE = 64.kilobytes

  get '/' do
    '<h1>Hello!</h1>'
  end

  get '/download' do
    proxied_headers = env.
      select { |key, _| key.starts_with?('HTTP_') && !key.starts_with?('HTTP_X_') }.
      transform_keys! do |key|
      ar = key.gsub(/^HTTP_/, '').split('_')

      ar.map! { |x| x.downcase.camelize }.join('-')
    end

    remote = HTTP.
      timeout(3).
      follow.
      headers(proxied_headers).
      get('http://192.168.3.4:5002/webdav/travels/2019_05_01%20-%20%D0%9A%D0%B0%D0%B7%D0%B0%D0%BD%D1%8C/10%20-%20%D0%9C%D0%B0%D0%BB%D0%BC%D1%8B%D0%B6-%D0%9A%D0%B0%D0%B7%D0%B0%D0%BD%D1%8C.mp4')

    remote.headers.each { |header, value| response.headers[header] = value }

    status remote.code

    stream do |out|
      remote.body.each do |chunk|
        break if out.closed?

        out << chunk
      end
    end
  end

  get '/download_local' do
    stream do |out|
      out.define_singleton_method(:write) { |data| self << data }

      Net::SFTP.start('storage', 'foo', {password: 'pass'}) do |sftp|
        sftp.download!(
          'upload/test',
          out,
          read_size: CHUNK_SIZE
        )
      end
    end
  end

  put '/upload' do
    halt 400, 'Bad Request' unless (files = params[:files]).present?

    files.each do |file|
      puts file[:type]
      io = file[:tempfile]

      Net::SFTP.start('storage', 'foo', password: 'pass') do |sftp|
        sftp.file.open("upload/#{file[:filename]}", 'w') do |f|
          loop do
            break if (chunk = io.read(CHUNK_SIZE)).nil?

            f.write chunk
          end
        end
      end
    end

    'OK'
  end
end
