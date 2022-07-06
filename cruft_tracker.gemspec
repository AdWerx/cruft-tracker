require_relative 'lib/cruft_tracker/version'

Gem::Specification.new do |spec|
  spec.name = 'cruft_tracker'
  spec.version = CruftTracker::VERSION
  spec.authors = ['Adwerx Inc.', 'Doug Hughes']
  spec.email = %w[dev@adwerx.com dhughes@adwerx.com]

  spec.summary =
    'Provides a system to track Ruby method usage somewhat unobtrusively.'
  spec.description = <<~DESCRIPTION
    Have you ever asked yourself, "Is this method even being used?!" Or, "What the heck is this method receiving?" Does your application use Rails? If the answers these questions are yes, this gem may be of use to you!
    
    Large applications can accrue cruft; old methods that might once have been important, but are now unused or code that is difficult to understand, but dangerous to refactor. Unfortunately, software is _complex_ and sometimes it's unclear what's really going on. This adds maintenance burdens, headaches, and uncertainty.
    
    This gem aims to give you a couple tools to make it easier to know what (and how) your code is being used (or not).

    CruftTracker supports Rails versions 5.2 to 6.1 at this time. As of now the gem only supports MySQL, but contributions for Postgres or other DBMS would be welcome.
  DESCRIPTION
  spec.homepage = 'https://github.com/AdWerx/cruft-tracker'
  spec.license = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files =
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'active_interaction', '~> 4.1'
  spec.add_dependency 'rails', '>= 5.2'

  spec.add_development_dependency 'appraisal', '~> 2.4.1'
  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'database_cleaner', '~> 2.0.1'
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
  spec.add_development_dependency 'prettier'
end
