# frozen_string_literal: true

require "yaml"
require "ostruct"

module App
  @config = YAML.load_file(File.join(__dir__, "../config/app.yml"))

  def self.config
    OpenStruct.new(@config["app"])
  end
end
