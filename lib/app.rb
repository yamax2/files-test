# frozen_string_literal: true

require 'active_support/core_ext/numeric/bytes'

require 'http'
require 'net/sftp'

require 'sinatra'
require 'sinatra/streaming'

class Application < Sinatra::Base
  helpers Sinatra::Streaming

  CHUNK_SIZE = 64.kilobytes

  get '/' do
    '<h1>Hello!</h1>'
  end

  get '/download' do
    response = HTTP.follow.get('https://e1.ru')

    stream do |out|
      response.body.each do |chunk|
        out.puts chunk
      end
    end
  end

  put '/upload' do
    Net::SFTP.start('storage', 'foo', password: 'pass') do |sftp|
      sftp.file.open('upload/test', 'w') do |f|
        until request.body.eof?
          chunk = request.body.read(CHUNK_SIZE)

          f.write chunk
        end
      end
    end
  end
end
