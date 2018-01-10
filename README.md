[![Build Status](https://travis-ci.org/TINYhr/tp_common.svg?branch=master)](https://travis-ci.org/TINYhr/tp_common)
[![Gem Version](https://badge.fury.io/rb/tp_common.svg)](https://badge.fury.io/rb/tp_common)

# TpCommon

This gem contains common libraries which shared between projects used in TINYpulse.

## Rails versions

From v0.2.0 `tp_common` support only rails > 4. Mostly on ActiveSupport DateTime functions and `Rails.config_for` method.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tp_common'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tp_common

## Usage

Reference http://www.rubydoc.info/gems/tp_common for more detail of each module.

## Publish

This gem is publised under TINYpulse devops account on https://rubygems.org/gems/tp_common, please contact devops team to release.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

Reference https://github.com/thoughtbot/appraisal to know using appraisal to test rails 4,5 integration.

**Need more test for (both unit tests and rails integration tests):**

* TpCommon::Timezones.list_zone_offsets

To run integration test

```bash
# Run unit test
$ bundle exec rspec
# Run integration test on 2 dependencies rails '~> 4.0' and rails '~> 5.0'
$ bundle exec appraisal rspec spec/integration/rails_custom_timezones_spec.rb && bundle exec appraisal rspec spec/integration/rails_spec.rb
#
# To run integration test on specific rails:
# Rails 4
$ bundle exec appraisal rails-4 rspec spec/integration/rails_custom_timezones_spec.rb && bundle exec appraisal rails-4 rspec spec/integration/rails_spec.rb
# Rails 5
$ bundle exec appraisal rails-5 rspec spec/integration/rails_custom_timezones_spec.rb && bundle exec appraisal rails-5 rspec spec/integration/rails_spec.rb

```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/TINYhr/tp_common. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TpCommon project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/TINYhr/tp_common/blob/master/CODE_OF_CONDUCT.md).
