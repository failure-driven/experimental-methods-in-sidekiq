# frozen_string_literal: true

module Sidekiq
  class CreateUser
    include Sidekiq::Worker

    def perform(name)
      user = nil
      User.transaction do
        user = User.create!(name: name)

        raise ArgumentError, App.config.fail_job_1 if App.config.fail_job_1
      end

      raise ArgumentError, App.config.fail_job_2 if App.config.fail_job_2

      # SendEmailJob.perform_async(user.id)
      SendEmailJob.perform_at(3.seconds.from_now, user.id) if user
    rescue ActiveRecord::RecordNotUnique => e
      $stdout.puts "RecordNotUnique: #{e.message}"
    end
  end
end
