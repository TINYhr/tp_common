module TpCommon
  # Hook libraries initialize to Rails if using in rails app.
  # Use this way to wait Rails.application is initialized, so we could use rails application config.
  #
  class Railtie < ::Rails::Railtie
    config.after_initialize do
      TpCommon::Timezones::Config.config
    end
  end
end
