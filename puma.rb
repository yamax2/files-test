# frozen_string_literal: true

environment ENV.fetch('RACK_ENV', 'development')

threads_count = ENV.fetch('PUMA_THREADS', 20).to_i
threads threads_count, threads_count

port ENV.fetch('PORT', 3000).to_i
