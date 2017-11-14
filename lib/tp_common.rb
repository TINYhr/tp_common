require "tp_common/version"
require 'active_support/all'
require 'psych'
require 'yaml'

# require 'pry-byebug'

module TpCommon
  def self.load_timezones
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
