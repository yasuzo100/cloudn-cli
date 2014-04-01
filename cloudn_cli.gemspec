# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cloudn_cli/version'

Gem::Specification.new do |spec|
  spec.name          = "cloudn_cli"
  spec.version       = Cloudn::Shell::VERSION
  spec.authors       = [""]
  spec.email         = [""]
  spec.description   = %q{Shell for Cloudn API}
  spec.summary       = %q{Shell for Cloudn API}
  spec.homepage      = ""
  spec.license       = ""

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  
  spec.add_dependency("termcolor")
  spec.add_dependency("crack")
  spec.add_dependency("coderay")
  spec.add_dependency("httpclient")
end

