require 'rails'
require 'action_controller/railtie'
require 'tp_common'

ActiveSupport::Deprecation.silenced = true

module ActiveRecord
  class RecordNotFound < StandardError
  end
end

class RailsApp < Rails::Application
  # For Rails 4.0+
  config.secret_key_base = 'test secret key base for test rails app'

  config.eager_load = true
  config.cache_classes = true
  config.serve_static_files = false
  config.consider_all_requests_local = false

  routes.append do
    root to: 'rails#index'
    get :list_count, to: 'rails#list_count'
    get :first_zone, to: 'rails#first_zone'

    get 'local_to_utc/test_1', to: 'local_to_utc#test_1'
    get 'local_to_utc/test_2', to: 'local_to_utc#test_2'
    get 'local_to_utc/test_3', to: 'local_to_utc#test_3'

    get 'relative_time_in_time_zone/test_1', to: 'relative_time_in_time_zone#test_1'
    get 'relative_time_in_time_zone/test_2', to: 'relative_time_in_time_zone#test_2'
    get 'relative_time_in_time_zone/test_3', to: 'relative_time_in_time_zone#test_3'

    get 'offset_in_words/test_1', to: 'offset_in_words#test_1'
    get 'offset_in_words/test_2', to: 'offset_in_words#test_2'
    get 'offset_in_words/test_3', to: 'offset_in_words#test_3'

    get 'converted_time/test_1', to: 'converted_time#test_1'
    get 'converted_time/test_2', to: 'converted_time#test_2'
    get 'converted_time/test_3', to: 'converted_time#test_3'
    get 'converted_time/test_4', to: 'converted_time#test_4'
  end
end

# Required for install command.
class ApplicationController < ActionController::Base
end

class RailsController < ApplicationController
  def index
    render plain: "Test app to test rails integration. Support rails 4+ only."
  end

  def list_count
    render plain: TpCommon::Timezones::LIST_ZONES.count
  end

  def first_zone
    key = TpCommon::Timezones::LIST_ZONES.keys.first
    render json: {
      key:  key,
      zone: TpCommon::Timezones::LIST_ZONES[key],
    }
  end
end

# Copy from: spec/tp_common/timezones_spec.rb
class LocalToUtcController < ApplicationController
  def test_1
    # 10 am GMT+7 time now

    test_time = Time.new(2017, 12, 1, 10, 0, 0, "+07:00")
    zone_key  = 'GMT_P0700'

    expected  = Time.new(2017, 12, 1, 3, 0, 0, "-00:00")

    render plain: (TpCommon::Timezones.local_to_utc(test_time, zone_key) == expected)
  end

  def test_2
    # 10 am GMT time now

    test_time = Time.new(2017, 12, 1, 10, 0, 0, "+00:00")
    zone_key  = 'GMT_M0000'

    expected  = Time.new(2017, 12, 1, 10, 0, 0, "-00:00")

    render plain: (TpCommon::Timezones.local_to_utc(test_time, zone_key) == expected)
  end

  def test_3
    # 10 am GMT-7 time now

    test_time = Time.new(2017, 12, 1, 10, 0, 0, "-07:00")
    zone_key  = 'GMT_M0700'

    expected  = Time.new(2017, 12, 1, 17, 0, 0, "-00:00")

    render plain: (TpCommon::Timezones.local_to_utc(test_time, zone_key) == expected)
  end
end

# Copy from: spec/tp_common/timezones_spec.rb
class RelativeTimeInTimeZoneController < ApplicationController
  def test_1
    # 10 am GMT+7 time now
    test_time = Time.new(2017, 12, 1, 10, 0, 0, "+00:00")
    zone_key  = 'GMT_P0700'

    expected  = DateTime.new(2017, 12, 1, 10, 0, 0, "+07:00")

    render plain: (TpCommon::Timezones.relative_time_in_time_zone(test_time, zone_key) == expected)
  end

  def test_2
    # 10 am GMT time now

    test_time = Time.new(2017, 12, 1, 10, 0, 0, "+00:00")
    zone_key  = 'GMT_M0000'

    expected  = DateTime.new(2017, 12, 1, 10, 0, 0, "+00:00")

    render plain: (TpCommon::Timezones.relative_time_in_time_zone(test_time, zone_key) == expected)
  end

  def test_3
    # 10 am GMT-7 time now

    test_time = Time.new(2017, 12, 1, 10, 0, 0, "+00:00")
    zone_key  = 'GMT_M0700'

    expected  = DateTime.new(2017, 12, 1, 10, 0, 0, "-07:00")

    render plain: (TpCommon::Timezones.relative_time_in_time_zone(test_time, zone_key) == expected)
  end
end

class OffsetInWordsController < ApplicationController
  def test_1
    render plain: TpCommon::Timezones.offset_in_words('UTC')
  end

  def test_2
    render plain: TpCommon::Timezones.offset_in_words('Asia/Tehran')
  end

  def test_3
    render plain: TpCommon::Timezones.offset_in_words('America/Los_Angeles')
  end
end

class ConvertedTimeController < ApplicationController
  def test_1
    test_time = nil
    zone_key  = 'GMT_P0700'

    expected  = nil

    render plain: (TpCommon::Timezones.converted_time(test_time, zone_key) == expected)
  end

  def test_2
    # in GMT- zone
    test_time = Time.new(2017, 12, 1, 10, 0, 0, "-00:00")
    zone_key  = 'GMT_M0700'

    expected  = Time.new(2017, 12, 1, 3, 0, 0, "-07:00")

    render plain: (TpCommon::Timezones.converted_time(test_time, zone_key) == expected)
  end

  def test_3
    # in GMT+ zone
    test_time = Time.new(2017, 12, 1, 10, 0, 0, "-00:00")
    zone_key  = 'GMT_P0700'

    expected  = Time.new(2017, 12, 1, 17, 0, 0, "+07:00")

    render plain: (TpCommon::Timezones.converted_time(test_time, zone_key) == expected)
  end

  def test_4
    # invalid zone
    test_time = Time.new(2017, 12, 1, 10, 0, 0, "-00:00")
    zone_key  = 'GMT_K0700'

    expected  = Time.new(2017, 12, 1, 10, 0, 0, "-00:00")

    render plain: (TpCommon::Timezones.converted_time(test_time, zone_key) == expected)
  end
end

Rails.env = 'production'
Rails.logger = Logger.new('/dev/null')
