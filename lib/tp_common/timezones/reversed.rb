module TpCommon
  module Timezones
    module Reversed
      def self.[](zone_name)
        TpCommon::Timezones::REVERSED_LIST_ZONES[similar_key(zone_name).to_sym]
      end

      def self.similar_key(zone_name)
        zone_name = zone_name.to_s.downcase
        if zone_name =~ /^(gmt[-\+]\d+)\.\d+$/
          zone_name.split('.').first
        else
          zone_name
        end
      end
      private_class_method :similar_key
    end
  end
end

# TpCommon::Timezones::Reversed['American Samoa']
