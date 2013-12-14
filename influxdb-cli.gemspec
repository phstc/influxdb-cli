# -*- encoding: utf-8 -*-

require File.expand_path(File.join(File.dirname(__FILE__), %w[lib influxdb_client version]))

Gem::Specification.new do |gem|
  gem.name          = 'influxdb-cli'
  gem.version       = InfluxDBClient::VERSION
  gem.authors       = ['Pablo Cantero']
  gem.email         = ['pablo@pablocantero.com']
  gem.description   = %q{Ruby CLI for InfluxDB}
  gem.summary       = %q{Ruby CLI for InfluxDB}
  gem.homepage      = 'https://github.com/phstc/influxdb-cli'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'influxdb'
  gem.add_dependency 'pry'
  gem.add_dependency 'thor', '~> 0.18.1'
  gem.add_dependency 'awesome_print'
  gem.add_dependency 'terminal-table'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency "bundler"
  gem.add_development_dependency "rake"
end

