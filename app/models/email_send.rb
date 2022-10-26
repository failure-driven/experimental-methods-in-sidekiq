# frozen_string_literal: true

class EmailSend < ActiveRecord::Base
  belongs_to :user
end
