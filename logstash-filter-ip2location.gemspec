Gem::Specification.new do |s|

  s.name            = 'logstash-filter-ip2location'
  s.version         = '2.1.3'
  s.licenses        = ['Apache License (2.0)']
  s.summary         = "Logstash filter IP2Location"
  s.description     = "IP2Location filter plugin for Logstash enables Logstash's users to add geolocation information such as country, state, city, latitude, longitude, ZIP code, time zone, ISP, domain name, connection speed, IDD code, area code, weather station code, weather station name, MNC, MCC, mobile brand, elevation and usage type by IP address."
  s.authors         = ["IP2Location"]
  s.email           = 'support@ip2location.com'
  s.homepage        = "https://www.ip2location.com"
  s.require_paths   = ["lib", "vendor/jar-dependencies"]

  # Files
  s.files = Dir["lib/**/*",'spec/**/*',"vendor/**/*","vendor/jar-dependencies/**/*.jar","*.gemspec","*.md","Gemfile","LICENSE"]

  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "filter" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core-plugin-api", "~> 2.0"
  s.add_development_dependency "logstash-devutils"
end
