require_relative 'lib/philia/version'

Gem::Specification.new do |spec|
  spec.name        = 'philia'
  spec.version     = Philia::VERSION
  spec.authors     = ['Phil Smy']
  spec.email       = ['phil@philsmy.com']
  spec.homepage    = 'https://github.com/philsmy/philia'
  spec.summary     = 'My version of Milia'
  spec.description = 'My version of Milia'
  spec.license     = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = "https://github.com/philsmy/philia"
  spec.metadata['changelog_uri'] = "https://github.com/philsmy/philia/CHANGELOG.md"

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'devise', '~> 4.8.0', '>= 4.8.0'
  spec.add_dependency 'rails', '~> 6.1.3', '>= 6.1.3.2'
end
