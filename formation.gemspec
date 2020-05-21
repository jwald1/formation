
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "formation/version"

Gem::Specification.new do |spec|
  spec.name          = "formation"
  spec.version       = Formation::VERSION
  spec.authors       = ["jwald1"]

  spec.summary       = %q{Form object for Rails}
  spec.description   = %q{Form object for Rails with validations build on top of ActiveModel.}
  spec.homepage      = "https://github.com/jwald1/formation"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  #   spec.metadata["homepage_uri"] = spec.homepage
  #   spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  #   spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", '~> 2.1', '>= 2.1.4'
  spec.add_development_dependency "pry", "~> 0.13.1"
  spec.add_development_dependency "rake", '~> 13.0', '>= 13.0.1'
  spec.add_development_dependency "rspec", '~> 3.9'
  spec.add_dependency "activemodel", '~> 6.0', '>= 6.0.3.1'
  spec.add_dependency "active_model_attributes", '~> 1.6'
  spec.add_dependency "actionpack", '~> 6.0', '>= 6.0.3.1'
end
