# frozen_string_literal: true

class CreateOutboxes < ActiveRecord::Migration[7.0]
  def change
    create_table :outboxes do |t|
      t.references :model, index: false, polymorphic: true, null: false
      t.string :event, null: false
      t.datetime :created_at, null: false
    end

    add_index(:outboxes, %i[model_type model_id event])
  end
end
