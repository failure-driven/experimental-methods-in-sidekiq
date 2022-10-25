# frozen_string_literal: true

require "bundler/setup"
Bundler.require(:default)

loader = Zeitwerk::Loader.new
loader.push_dir(File.join(__dir__, "../config"))
loader.push_dir(File.join(__dir__, "../app/jobs"))
loader.enable_reloading
loader.setup

my_filewatcher = Filewatcher.new(File.join(__dir__, ".."))
Thread.new(my_filewatcher) do |fw|
  fw.watch do |filename|
    puts "config re-loaded ✅"
    loader.reload
  end
end

Sidekiq.configure_client do |config|
  config.redis = {db: 1}
end

Sidekiq.configure_server do |config|
  config.redis = {db: 1}
end
