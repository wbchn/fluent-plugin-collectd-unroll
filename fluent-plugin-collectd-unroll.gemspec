# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = "fluent-plugin-collectd-unroll"
  gem.description = "Output filter plugin to rewrite Collectd JSON output to flat json"
  gem.homepage    = "https://github.com/CiscoZeus/fluent-plugin-collectd-unroll"
  gem.summary     = gem.description
  gem.version     = File.read("VERSION").strip
  gem.authors     = ["Manoj Sharma"]
  gem.email       = "vigyanik@gmail.com"
  gem.has_rdoc    = false
  #gem.platform    = Gem::Platform::RUBY
  gem.license     = 'MIT'
  gem.files       = `git ls-files`.split("\n")
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.add_dependency "fluentd", ">= 1.2.0"
  gem.add_development_dependency "rake", ">= 0.9.2"
end
