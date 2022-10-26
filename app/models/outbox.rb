# frozen_string_literal: true

class Outbox < ActiveRecord::Base
  belongs_to :model, polymorphic: true
end
