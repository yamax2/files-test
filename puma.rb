# frozen_string_literal: true

threads_count = ENV.fetch('PUMA_THREADS', 2).to_i
threads threads_count, threads_count

port ENV.fetch('PORT', 3000).to_i
