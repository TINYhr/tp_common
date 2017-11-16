module TpCommon
  module Timezones
    class Zone
      SECONDS_IN_AN_HOUR = 3600

      attr_reader :key

      def initialize(time, key, name, title)
        @name = name
        @key = key
        @time = time
        @title = title
      end

      def offset
        base_offset = (time_difference_in_seconds / SECONDS_IN_AN_HOUR).abs

        zone = Time.find_zone(@title)
        if !zone.nil? && zone.parse(@time.to_date.to_s).dst?
          base_offset = base_offset - 1
        end

        base_offset
      end

      def date
        gmt_12.to_date
      end

      private

      def gmt_12
        @time.in_time_zone('Etc/GMT-12')
      end

      def organization_time
        @time.in_time_zone(@name)
      end

      def time_difference_in_seconds
        gmt_12.utc_offset - organization_time.utc_offset
      end

    end
  end
end
