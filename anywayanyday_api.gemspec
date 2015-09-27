# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'anywayanyday_api/version'

Gem::Specification.new do |spec|
  spec.name          = "anywayanyday_api"
  spec.version       = AnywayanydayApi::VERSION
  spec.authors       = ["Alexey Gordienko"]
  spec.email         = ["alx@anadyr.org"]
  spec.summary       = %q{Anywayanyday API (Redirect)}
  spec.description   = %q{Ruby gem for Anywayanyday API Redirect.}
  spec.homepage      = "http://github.com/gordienko/anywayanyday_api"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.add_dependency 'rest-client'
  spec.add_dependency 'nokogiri'
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
