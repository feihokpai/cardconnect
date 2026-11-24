source 'https://rubygems.org'

gem 'rake'
gem 'yard'

# The CI matrix overrides these requirements to cover the supported ranges.
# See .github/workflows/ci.yml
gem 'faraday', ENV['FARADAY_VERSION'] if ENV['FARADAY_VERSION']

group :test do
  gem 'json', ENV.fetch('JSON_VERSION', '>= 3')
  gem 'minitest', '~> 5.4'
end

# Specify your gem's dependencies in cardconnect.gemspec
gemspec
