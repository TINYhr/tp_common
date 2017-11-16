require 'tp_common/timezones/config'

module TpCommon
  module Timezones
    # LIST_ZONES = # Dynamic defined in TpCommon::Timezones::Config

    def self.current_date_in_time_zone(time_zone_key)
      self.converted_time(Time.now, time_zone_key).strftime('%Y-%m-%d %H:%M:%S').to_date
    end

    def self.offset_in_words(zone_name)
      offset = Time.now.in_time_zone(zone_name).utc_offset
      in_words = 'GMT'

      hours = offset.abs / (60 * 60)

      in_words << (offset > 0 ? '+' : '-')
      in_words << format('%01d', hours)
      in_words
    end

    def self.zone_title(zone)
      zone_value = LIST_ZONES[zone]
      return nil unless zone_value

      dst_icon = zone_value[:dst] ? '☀️' : ''

      [zone_value[:title], self.offset_in_words(zone_value[:name]), dst_icon].reject{|part| part.empty? }.join(" ")
    end

    def self.zone_title_without_dst(zone)
      zone_value = LIST_ZONES[zone]
      return nil unless zone_value

      [zone_value[:title], self.offset_in_words(zone_value[:name])].reject{|part| part.empty? }.join(" ")
    end

    def self.list_for_select
      LIST_ZONES.map{ |k, v| [self.zone_title(k), k] }
    end

    # return hash offsets. Ex: {'GMT' => 0, ...}
    def self.list_zone_offsets
      Hash[LIST_ZONES.map{ |k, v| [k, Time.now.in_time_zone(v[:name]).utc_offset] }]
    end

    def self.local_to_utc(time, zone)
      zone_value = LIST_ZONES[zone]
      ActiveSupport::TimeZone.new(zone_value[:name]).local_to_utc(time)
    end

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

    def self.zone_abbreviation(time_zone_key)
      zone_value = LIST_ZONES[time_zone_key]
      zone_value[:name]
    end

    def self.relative_time_in_time_zone(time, time_zone_key)
      zone = zone_abbreviation(time_zone_key)
      DateTime.parse(time.strftime("%d %b %Y %H:%M:%S #{time.in_time_zone(zone).formatted_offset}"))
    end
  end
end
