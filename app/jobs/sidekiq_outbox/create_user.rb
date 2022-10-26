# frozen_string_literal: true

module SidekiqOutbox
  class CreateUser
    include Sidekiq::Worker

    def perform(name)
      outbox = nil
      User.transaction do
        user = User.create!(name: name)

        raise ArgumentError, App.config.fail_job_1 if App.config.fail_job_1

        outbox = Outbox.create(model: user, event: "email_send")
      end

      raise ArgumentError, App.config.fail_job_2 if App.config.fail_job_2

      SidekiqOutbox::Worker.perform_at(3.seconds.from_now, outbox.id) if outbox
    rescue ActiveRecord::RecordNotUnique => e
      $stdout.puts "RecordNotUnique: #{e.message}"
    end
  end
end
