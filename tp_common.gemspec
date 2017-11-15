# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "tp_common/version"

Gem::Specification.new do |spec|
  spec.name          = "tp_common"
  spec.version       = TpCommon::VERSION
  spec.authors       = ["An Vo"]
  spec.email         = ["thien.an.vo.nguyen@gmail.com"]

  spec.summary       = "Common libraries used for TINYpulse apps"
  spec.description   = "Common libraries used for TINYpulse apps. i.e. Timezone, ..."
  spec.homepage      = "https://github.com/anvox/tp_common"
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

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry-byebug", '~> 3'
  spec.add_development_dependency "timecop", '~> 0.9'

  spec.add_runtime_dependency "psych", '~> 2'
  spec.add_runtime_dependency "tzinfo", '~> 1.2', '>= 1.2.0'
  spec.add_runtime_dependency "activesupport", '~> 4.2', '>= 4.2.0'
end
