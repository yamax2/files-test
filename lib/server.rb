# frozen_string_literal: true

require 'active_support/core_ext/numeric/bytes'

require 'net/sftp'

class Server
  CHUNK_SIZE = 64.kilobytes

  def call(env) # rubocop:disable Metrics/MethodLength
    req = Rack::Request.new(env)

    Net::SFTP.start('storage', 'foo', password: 'pass') do |sftp|
      sftp.file.open('upload/test', 'w') do |f|
        loop do
          chunk = req.body.read(CHUNK_SIZE)
          break unless chunk

          f.write chunk
        end
      end
    end

    [200, {'Content-Type' => 'plain/text'}, ['OK']]
  end
end
