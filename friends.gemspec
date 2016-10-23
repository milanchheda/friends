# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "friends/version"

Gem::Specification.new do |spec|
  spec.name          = "friends"
  spec.version       = Friends::VERSION
  spec.authors       = ["Jacob Evelyn"]
  spec.email         = ["jacobevelyn@gmail.com"]
  spec.summary       = "Spend time with the people you care about."
  spec.description   = "Spend time with the people you care about. "\
                       "Introvert-tested. Extrovert-approved."
  spec.homepage      = "https://github.com/JacobEvelyn/friends"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = ["friends"]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  # We need Ruby 2.0's keyword arguments and default UTF-8 encoding.
  spec.required_ruby_version = ">= 2.1"

  spec.add_dependency "chronic", "~> 0.10"
  spec.add_dependency "gli", "~> 2.12"
  spec.add_dependency "memoist", "~> 0.15"
  spec.add_dependency "paint", "~> 1.0"
  spec.add_dependency "semverse", "~> 1.2"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "codeclimate-test-reporter", "~> 0.5"
  spec.add_development_dependency "minitest", "~> 5.5"
  spec.add_development_dependency "overcommit", "~> 0.34"
  spec.add_development_dependency "minitest-parallel_fork", "~> 1.0"
  spec.add_development_dependency "rake", "~> 11.2"
  spec.add_development_dependency "rubocop", "~> 0.40"
end
