# frozen_string_literal: true

require_relative './lib/server'

Rack::Utils.key_space_limit = 100.megabytes
use Rack::Reloader

run Server.new
