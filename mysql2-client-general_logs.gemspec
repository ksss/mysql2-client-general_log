# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
File.read('lib/mysql2/client/general_log/version.rb') =~ /.*VERSION\s*=\s*['"](.*?)['"]\s.*/
version = $1

Gem::Specification.new do |spec|
  spec.name          = "mysql2-client-general_log"
  spec.version       = version
  spec.authors       = ["ksss"]
  spec.email         = ["co000ri@gmail.com"]

  spec.summary       = %q{Simple stocker general log for mysql2 gem.}
  spec.description   = %q{Simple stocker general log for mysql2 gem.}
  spec.homepage      = "https://github.com/ksss/mysql2-client-general_log"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "mysql2"
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rgot"
end
