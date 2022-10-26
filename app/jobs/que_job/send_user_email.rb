# frozen_string_literal: true

module QueJob
  class SendUserEmail < Que::Job
    # Default settings for this job. These are optional - without them, jobs
    # will default to priority 100 and run immediately.
    self.run_at = proc { 1.second.from_now }

    # We use the Linux priority scale - a lower number is more important.
    self.priority = 10

    def run(user_id)
      user = User.find(user_id)
      EmailSend.transaction do
        user = EmailSend.create!(user: user)

        finish # maintains job history
      end
    end
  end
end
