# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'infra_operator/version'

Gem::Specification.new do |spec|
  spec.name          = "infra_operator"
  spec.version       = InfraOperator::VERSION
  spec.authors       = ["Shota Fukumori (sora_h)"]
  spec.email         = ["her@sorah.jp"]

  spec.summary       = %q{Operator}
  spec.homepage      = "https://github.com/sorah/infra_operator"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'sfl' # spawn-for-legacy

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
