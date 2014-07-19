# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sauerkraut/version'

Gem::Specification.new do |spec|
  spec.name          = "sauerkraut"
  spec.version       = Sauerkraut::VERSION
  spec.authors       = ["Vasanth Pappu"]
  spec.email         = ["rubycoder@example.com"]
  spec.summary       = %q{Helps refactor cucumber steps.}
  spec.description   = %q{Gathers all step definition source code for a given scenario or range, and outputs it in one place.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "colorize", "~> 0"
end
