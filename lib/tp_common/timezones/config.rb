module TpCommon
  module Timezones
    class Config
      # Try to load TpCommon::Timezones::LIST_ZONES in config/timezones.yml from rails app.
      # if not, load the default in timezones/config/timezones.yml
      def self.config
        return if TpCommon::Timezones.const_defined?("LIST_ZONES")
        if defined?(::Rails::Railtie)
          begin
            TpCommon::Timezones.const_set("LIST_ZONES", Rails.application.config_for(:timezones))
            puts "[TpCommon::Timezones::Config] Message-3: Use custom timezones in project config/timezones.yml"
            return
          rescue NameError, NoMethodError
            puts "[TpCommon::Timezones::Config] Message-1: Use default timezones in tp_common/timezones/config/timezones.yml"
          rescue StandardError
            puts "[TpCommon::Timezones::Config] Message-2: Use default timezones in tp_common/timezones/config/timezones.yml"
          end
        end

        TpCommon::Timezones.const_set("LIST_ZONES", load_default_timezones)
      end

      # Private
      # Load the default TpCommon::Timezones::LIST_ZONES in timezones/config/timezones.yml
      # This method is clone from Rails' config_for
      #
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
