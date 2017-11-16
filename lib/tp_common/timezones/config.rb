module TpCommon
  module Timezones
    class Config
      def self.config
        return if TpCommon::Timezones.const_defined?("LIST_ZONES")
        if defined?(::Rails::Railtie)
          begin
            TpCommon::Timezones.const_set("LIST_ZONES", Rails.application.config_for(:timezones))
            return
          rescue NameError, NoMethodError
            puts "Couldn't load Rails or config methods. Use default."
          rescue StandardError
            puts "Couldn't load file config/timezones.yml. Use default."
          end
        end

        TpCommon::Timezones.const_set("LIST_ZONES", load_default_timezones)
      end

      def self.load_default_timezones
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
      private_class_method :load_default_timezones
    end
  end
end
