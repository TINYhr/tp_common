require "tp_common/app_config/environment"

module TpCommon
  module AppConfig
    def self.[](key)
      TpCommon::AppConfig::Environment.fetch(key)
    end
  end
end
