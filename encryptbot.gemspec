
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "encryptbot/version"

Gem::Specification.new do |spec|
  spec.name          = "encryptbot"
  spec.version       = Encryptbot::VERSION
  spec.authors       = ["danlewis"]
  spec.email         = [""]

  spec.summary       = %q{Manage Let's Encrypt wildcard certificates on Heroku}
  spec.description   = %q{Manage Let's Encrypt wildcard certificates on Heroku}
  spec.homepage      = "https://github.com/danlewis/encryptbot"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "acme-client"
  spec.add_dependency "platform-api"
  spec.add_dependency "faraday"
  spec.add_dependency "aws-sdk-route53"
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", ">= 12.3.3"
end
