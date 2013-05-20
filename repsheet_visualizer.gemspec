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

  spec.add_dependency "redis", "3.0.3"
  spec.add_dependency "json", "1.7.7"
  spec.add_dependency "sinatra", "1.4.1"
  
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 10.0.4"
  spec.add_development_dependency "unicorn", "~> 4.6.2"
end
