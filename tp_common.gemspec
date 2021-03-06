# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "tp_common/version"

Gem::Specification.new do |spec|
  spec.name          = "tp_common"
  spec.version       = TpCommon::VERSION
  spec.authors       = ["TINYpulse Devops"]
  spec.email         = ["devops@tinypulse.com"]

  spec.summary       = "Common libraries used for TINYpulse apps"
  spec.description   = "Common libraries used for TINYpulse apps. i.e. Timezone, ..."
  spec.homepage      = "https://github.com/TINYhr/tp_common"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = 'https://rubygems.org'
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '>= 1.17.3'
  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry-byebug", '~> 3'
  spec.add_development_dependency "timecop", '~> 0.9'
  spec.add_development_dependency "appraisal", '~> 2.2', '>= 2.2.0'
  spec.add_development_dependency "webmock"

  spec.add_runtime_dependency "tzinfo", '~> 1.2', '>= 1.2.0'
  spec.add_runtime_dependency "activesupport", '< 7.0', '>= 4.2.0'
  spec.add_runtime_dependency 'fog-aws', '~> 2.0'
  # fog-aws need a mime-type tool
  spec.add_runtime_dependency 'mime-types', '~> 3.2'

  spec.add_runtime_dependency 'aws-sdk-s3', '~> 1.19'
end
