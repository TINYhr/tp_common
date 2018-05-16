require 'tp_common/timezones/config'

module TpCommon
  # Helper methods for handle, display timezones.
  # Use TP's custom mapping timezones instead of ActiveRecord or TzInfo
  #
  module Timezones
    # LIST_ZONES = # Dynamic defined in TpCommon::Timezones::Config

    # Get current date in specific timezone.
    # timezone is LIST_ZONES[time_zone_key]
    #
    def self.current_date_in_time_zone(time_zone_key)
      self.converted_time(Time.now.utc, time_zone_key).strftime('%Y-%m-%d %H:%M:%S').to_date
    end

    # Human readable offset: GMT+7, GMT-9,...
    def self.offset_in_words(zone_name)
      offset = Time.now.in_time_zone(zone_name).utc_offset
      in_words = 'GMT'

      hours = offset.abs / (60 * 60)

      in_words << (offset > 0 ? '+' : '-')
      in_words << format('%01d', hours)
      in_words
    end

    # Zone title which display in select options.
    # if this zone applied DST, display sun_emoji at tail
    # Display as: title + offset_in_words [+ sun_emoji]
    #
    def self.zone_title(zone)
      zone_value = LIST_ZONES[zone]
      return nil unless zone_value

      dst_icon = zone_value[:dst] ? '☀️' : ''

      [zone_value[:title], self.offset_in_words(zone_value[:name]), dst_icon].reject{|part| part.empty? }.join(" ")
    end

    # The same as (see #zone_title) but doesn't display DST sun_emoji
    #
    def self.zone_title_without_dst(zone)
      zone_value = LIST_ZONES[zone]
      return nil unless zone_value

      [zone_value[:title], self.offset_in_words(zone_value[:name])].reject{|part| part.empty? }.join(" ")
    end

    # LIST_ZONES which map to format [text_to_display, key_identity]
    # For use in render select tag
    #
    def self.list_for_select
      LIST_ZONES.map{ |k, v| [self.zone_title(k), k] }
    end

    # return hash offsets. Ex: {'GMT' => 0, ...}
    #
    def self.list_zone_offsets
      Hash[LIST_ZONES.map{ |k, v| [k, Time.now.in_time_zone(v[:name]).utc_offset] }]
    end

    # Convert back a time in zone (defined in LIST_ZONES) to utc time
    #
    def self.local_to_utc(time, zone)
      zone_value = LIST_ZONES[zone]
      (ActiveSupport::TimeZone.new(zone_value[:title]) ||
        ActiveSupport::TimeZone.new(zone_value[:name])).local_to_utc(time)
    end

    # Opposite of #local_to_utc It conver a time to time in zone defined in LIST_ZONES
    #
    def self.converted_time(time, zone)
      if time
        zone_value = LIST_ZONES[zone]

        if zone_value
          time.in_time_zone(zone_value[:name])
        else
          time
        end
      end
    end

    # Get zone name by time_zone_key
    #
    def self.zone_abbreviation(time_zone_key)
      zone_value = LIST_ZONES[time_zone_key]
      zone_value[:name]
    end

    # Return a DateTime object of param time in specific timezone decide by time_zone_key
    #
    def self.relative_time_in_time_zone(time, time_zone_key)
      zone = zone_abbreviation(time_zone_key)
      DateTime.parse(time.strftime("%d %b %Y %H:%M:%S #{time.in_time_zone(zone).formatted_offset}"))
    end
  end
end
