# frozen_string_literal: true

require 'http'
require 'sinatra'
require 'sinatra/streaming'

class Application < Sinatra::Base
  helpers Sinatra::Streaming

  get '/' do
    '<h1>Hello!</h1>'
  end

  get '/test' do
    response = HTTP.follow.get('https://e1.ru')

    stream do |out|
      response.body.each do |chunk|
        out.puts chunk
      end
    end
  end
end
