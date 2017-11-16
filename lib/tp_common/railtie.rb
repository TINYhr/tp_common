module TpCommon
  class Railtie < ::Rails::Railtie
    config.after_initialize do
      TpCommon::Timezones::Config.config
    end
  end
end
