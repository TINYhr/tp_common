require "tp_common/version"
require 'active_support/all'
require 'psych'
require 'yaml'

module TpCommon
  def self.load_timezones
    begin
      return Rails.application.config_for(:timezones)
    rescue NameError
      "No Rails."
    rescue NoMethodError
      "Rails has no `application` or `config_for`."
    rescue StandardError
      "No config/timezones.yaml or the unable to parse. Use default"
    end

    file_path = File.join(File.dirname(__FILE__),"config/timezones.yml")
    yaml = Pathname.new(file_path)

    if yaml.exist?
      require "erb"
      (YAML.load(ERB.new(yaml.read).result) || {})["all_zones"] || {}
    else
      raise "Could not load configuration. No such file - #{yaml}"
    end
  rescue Psych::SyntaxError => e
    raise "YAML syntax error occurred while parsing #{yaml}. ",
            "Please note that YAML must be consistently indented using spaces. Tabs are not allowed. ",
            "Error: #{e.message}"
  end
end

require "tp_common/timezones"
require "tp_common/timezones/zone"
