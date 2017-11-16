require "tp_common/version"
require 'active_support/all'
require 'psych'
require 'yaml'

if defined?(::Rails::Railtie)
  require 'tp_common/railtie'
end

# Main scope of libraries.
# Dont put anything here.
#
module TpCommon
end

require "tp_common/timezones"
require "tp_common/timezones/zone"
