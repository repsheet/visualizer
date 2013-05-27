# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'repsheet_visualizer/version'

Gem::Specification.new do |spec|
  spec.name          = "repsheet_visualizer"
  spec.version       = RepsheetVisualizer::VERSION
  spec.authors       = ["Aaron Bedra"]
  spec.email         = ["aaron@aaronbedra.com"]
  spec.description   = %q{Visualizer for Repsheet}
  spec.summary       = %q{A visualization package for Repsheet}
  spec.homepage      = "https://github.com/Repsheet/visualizer"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "geoip"
  spec.add_dependency "json"
  spec.add_dependency "redis"
  spec.add_dependency "sinatra"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "unicorn"
end
