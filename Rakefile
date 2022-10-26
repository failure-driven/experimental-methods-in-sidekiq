# frozen_string_literal: true

# needed for ActiveRecord to be loaded
$LOAD_PATH << __dir__
require "config/environment"

# standalone_migrations-7.1.0/lib/standalone_migrations/configurator.rb
# does
#   def load_from_file(defaults)
#     return nil unless File.exists? configuration_file
#     ...
# but:
#   File.exists? is not a method in ruby 3?
class File
  def self.exists?(...) = exist?(...)
end

# to get around schema_format error
# NoMethodError: undefined method `schema_file' for primary:Module
#  default_schema = ENV['SCHEMA'] || \
#  ActiveRecord::Tasks::DatabaseTasks.schema_file(ActiveRecord::Base.schema_format)
#                                    ^^^^^^^^^^^^
ENV["SCHEMA"] ||= "db/schema.rb"

require "standalone_migrations"
StandaloneMigrations::Tasks.load_tasks
