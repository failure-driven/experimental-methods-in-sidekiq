# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name, index: {unique: true}, null: false
      t.datetime :created_at, null: false
    end
  end
end
