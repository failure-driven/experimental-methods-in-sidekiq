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

ActiveRecord::Schema[7.0].define(version: 2022_10_25_444444) do
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

  create_table "que_jobs", comment: "5", force: :cascade do |t|
    t.integer "priority", limit: 2, default: 100, null: false
    t.timestamptz "run_at", default: -> { "now()" }, null: false
    t.text "job_class", null: false
    t.integer "error_count", default: 0, null: false
    t.text "last_error_message"
    t.text "queue", default: "default", null: false
    t.text "last_error_backtrace"
    t.timestamptz "finished_at"
    t.timestamptz "expired_at"
    t.jsonb "args", default: [], null: false
    t.jsonb "data", default: {}, null: false
    t.integer "job_schema_version", default: 1
    t.index ["args"], name: "que_jobs_args_gin_idx", opclass: :jsonb_path_ops, using: :gin
    t.index ["data"], name: "que_jobs_data_gin_idx", opclass: :jsonb_path_ops, using: :gin
    t.index ["job_schema_version", "queue", "priority", "run_at", "id"], name: "que_poll_idx_with_job_schema_version", where: "((finished_at IS NULL) AND (expired_at IS NULL))"
    t.index ["queue", "priority", "run_at", "id"], name: "que_poll_idx", where: "((finished_at IS NULL) AND (expired_at IS NULL))"
    t.check_constraint "char_length(\nCASE job_class\n    WHEN 'ActiveJob::QueueAdapters::QueAdapter::JobWrapper'::text THEN (args -> 0) ->> 'job_class'::text\n    ELSE job_class\nEND) <= 200", name: "job_class_length"
    t.check_constraint "char_length(last_error_message) <= 500 AND char_length(last_error_backtrace) <= 10000", name: "error_length"
    t.check_constraint "char_length(queue) <= 100", name: "queue_length"
    t.check_constraint "jsonb_typeof(args) = 'array'::text", name: "valid_args"
    t.check_constraint "jsonb_typeof(data) = 'object'::text AND (NOT data ? 'tags'::text OR jsonb_typeof(data -> 'tags'::text) = 'array'::text AND jsonb_array_length(data -> 'tags'::text) <= 5 AND que_validate_tags(data -> 'tags'::text))", name: "valid_data"
  end

  create_table "que_lockers", primary_key: "pid", id: :integer, default: nil, force: :cascade do |t|
    t.integer "worker_count", null: false
    t.integer "worker_priorities", null: false, array: true
    t.integer "ruby_pid", null: false
    t.text "ruby_hostname", null: false
    t.text "queues", null: false, array: true
    t.boolean "listening", null: false
    t.integer "job_schema_version", default: 1
    t.check_constraint "array_ndims(queues) = 1 AND array_length(queues, 1) IS NOT NULL", name: "valid_queues"
    t.check_constraint "array_ndims(worker_priorities) = 1 AND array_length(worker_priorities, 1) IS NOT NULL", name: "valid_worker_priorities"
  end

  create_table "que_values", primary_key: "key", id: :text, force: :cascade do |t|
    t.jsonb "value", default: {}, null: false
    t.check_constraint "jsonb_typeof(value) = 'object'::text", name: "valid_value"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.index ["name"], name: "index_users_on_name", unique: true
  end

end
