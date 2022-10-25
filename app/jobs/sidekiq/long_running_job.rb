# frozen_string_literal: true

module Sidekiq
  class LongRunningJob
    include Sidekiq::Job

    def perform(duration = 60)
      @start = Time.now
      while (Time.now.to_i - @start.to_i) < duration
        sleep 1
      end
    end
  end
end
