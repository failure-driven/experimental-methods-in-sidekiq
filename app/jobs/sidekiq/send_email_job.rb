# frozen_string_literal: true

module Sidekiq
  class SendEmailJob
    include Sidekiq::Worker

    def perform(user_id)
      EmailSend.create!(user: User.find(user_id))
    end
  end
end
