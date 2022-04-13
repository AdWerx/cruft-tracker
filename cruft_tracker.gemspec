require_relative "lib/cruft_tracker/version"

Gem::Specification.new do |spec|
  spec.name        = "cruft_tracker"
  spec.version     = CruftTracker::VERSION
  spec.authors     = ["Doug Hughes"]
  spec.email       = ["dhughes@adwerx.com"]

  spec.summary = 'Provides a system to track method usage somewhat unobtrusively.'
  spec.description = 'Provides a system to track method usage somewhat unobtrusively.'
  # spec.homepage = 'https://github.com/dhughes/is_this_used'
  spec.license = 'MIT'

  # spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  # spec.add_dependency "rails", ">= 5.2"

  spec.add_development_dependency 'appraisal', '~> 2.4.1'
  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'generator_spec', '~> 0.9.4'
  spec.add_development_dependency 'mysql2', '~> 0.5.3'
  spec.add_development_dependency 'pry-byebug', '~> 3.9'
  spec.add_development_dependency 'rails', '>= 5.2'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-rails', '~> 5.0.2'
  spec.add_development_dependency 'rubocop', '~> 1.22.2'
  spec.add_development_dependency 'rubocop-rails', '~> 2.12.4'
  spec.add_development_dependency 'rubocop-rake', '~> 0.6.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.5.0'
end
