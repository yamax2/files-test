require 'sinatra'

class Application < Sinatra::Base
  get '/' do
    logger.info 'hello'

    '<h1>Hello!</h1>'
  end
end
