# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_10_25_333333) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "email_sends", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.index ["user_id"], name: "index_email_sends_on_user_id"
  end

  create_table "outboxes", force: :cascade do |t|
    t.string "model_type", null: false
    t.bigint "model_id", null: false
    t.string "event", null: false
    t.datetime "created_at", null: false
    t.index ["model_type", "model_id", "event"], name: "index_outboxes_on_model_type_and_model_id_and_event"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.index ["name"], name: "index_users_on_name", unique: true
  end

end
