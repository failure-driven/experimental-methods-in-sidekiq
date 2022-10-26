# frozen_string_literal: true

module SidekiqOutbox
  class Worker
    include Sidekiq::Worker

    def perform(outbox_id)
      Outbox.transaction do
        outbox = Outbox.find(outbox_id)
        raise ArgumentException unless outbox.event == "email_send"

        EmailSend.create!(user: outbox.model)
        outbox.destroy
      end
    end
  end
end
