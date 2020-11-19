# frozen_string_literal: true

require_relative './lib/app'

Rack::Utils.key_space_limit = 100.megabytes

run Application
