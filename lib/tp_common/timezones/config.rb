module TpCommon
  module Timezones
    class Config
      # Try to load TpCommon::Timezones::LIST_ZONES in config/timezones.yml from rails app.
      # if not, load the default in timezones/config/timezones.yml
      def self.config
        config_list_zones
        config_reversed_list_zones
      end

      def self.config_list_zones
        return if TpCommon::Timezones.const_defined?("LIST_ZONES")

        return if defined?(::Rails::Railtie) && load_rails_time_zones
        TpCommon::Timezones.const_set("LIST_ZONES", load_default_timezones)
      end
      private_class_method :config_list_zones

      def self.config_reversed_list_zones
        return if TpCommon::Timezones.const_defined?("REVERSED_LIST_ZONES")

        return if defined?(::Rails::Railtie) && load_rails_reversed_time_zones
        TpCommon::Timezones.const_set("REVERSED_LIST_ZONES",
                                      reversed_time_zone_lookup_table(load_default_reversed_timezones))
      end
      private_class_method :config_reversed_list_zones

      # Private
      def self.load_rails_time_zones
        begin
          TpCommon::Timezones.const_set("LIST_ZONES", Rails.application.config_for(:timezones))
          Rails.logger.debug "[TpCommon::Timezones::Config] Message-3: Use custom timezones in project config/timezones.yml"
          return true
        rescue NameError, NoMethodError
          Rails.logger.debug "[TpCommon::Timezones::Config] Message-1: Use default timezones in tp_common/timezones/config/timezones.yml"
        rescue StandardError
          Rails.logger.debug "[TpCommon::Timezones::Config] Message-2: Use default timezones in tp_common/timezones/config/timezones.yml"
        end

        false
      end
      private_class_method :load_rails_time_zones

      def self.load_rails_reversed_time_zones
        begin
          TpCommon::Timezones.const_set("REVERSED_LIST_ZONES",
                                        reversed_time_zone_lookup_table(Rails.application.config_for(:reversed)))
          return true
        rescue NameError, NoMethodError, StandardError
        end

        false
      end
      private_class_method :load_rails_time_zones

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
        raise <<~ERRMSG
          YAML syntax error occurred while parsing #{yaml}. 
          Please note that YAML must be consistently indented using spaces. Tabs are not allowed. 
          Error: #{e.message}
        ERRMSG
      end
      private_class_method :load_default_timezones

      def self.load_default_reversed_timezones
        file_path = File.join(File.dirname(__FILE__),"config/reversed.yml")
        yaml = Pathname.new(file_path)

        if yaml.exist?
          require "erb"
          (YAML.load(ERB.new(yaml.read).result) || {})["all_zones"] || {}
        else
          raise "Could not load configuration. No such file - #{yaml}"
        end
      rescue Psych::SyntaxError => e
        raise <<~ERRMSG
          YAML syntax error occurred while parsing #{yaml}. 
          Please note that YAML must be consistently indented using spaces. Tabs are not allowed. 
          Error: #{e.message}
        ERRMSG
      end
      private_class_method :load_default_reversed_timezones

      def self.reversed_time_zone_lookup_table(data_config)
        data_config.inject({}) do |carry, (zone_key, list_zone)|
          zone_key = zone_key.to_sym
          list_zone.each do |zone_name|
            carry[zone_name.downcase.to_sym] = zone_key
          end

          carry
        end
      end
    end
  end
end
