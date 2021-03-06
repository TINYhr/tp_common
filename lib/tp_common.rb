require "tp_common/version"
require 'active_support/all'
require 'psych'
require 'yaml'

if defined?(::Rails::Railtie)
  raise Gem::DependencyError.new('Rails version < 4 is not supported.') if ::Rails::VERSION::MAJOR < 4
  require 'tp_common/railtie'
end

# Main scope of libraries.
# Dont put anything here.
#
module TpCommon
end

require "tp_common/timezones"
require "tp_common/timezones/zone"
require "tp_common/timezones/reversed"
require "tp_common/assets_loader"
require "tp_common/asset_loaders/remote_assets_loader"
require "tp_common/file_storage"
require "tp_common/app_config"
