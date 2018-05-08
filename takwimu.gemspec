# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "takwimu/version"

Gem::Specification.new do |spec|
  spec.name          = "takwimu"
  spec.version       = Takwimu::VERSION
  spec.authors       = ["schneems"]
  spec.email         = ["richard.schneeman@gmail.com"]

  spec.summary       = 'Ruby GC stats => StatsD'
  spec.description   = 'Report GC usage data to StatsD.'
  spec.homepage      = 'https://github.com/jdejong/takwimu'
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'statsd-ruby', '~> 1.1'
  spec.required_ruby_version = '>= 2.2.0'

  spec.add_runtime_dependency 'multi_json', '~> 1'

  spec.add_development_dependency 'rake', '~> 10'
  spec.add_development_dependency 'minitest', '~> 5.3'
  spec.add_development_dependency "bundler", "~> 1.15"
end
