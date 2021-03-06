require "bundler/setup"

require "timecop"
require "pry-byebug"

FIXTURES_PATH ||= Pathname.new(File.expand_path('../fixtures/', __FILE__))
Dir["./spec/support/integration/share_examples/*.rb"].sort.each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
