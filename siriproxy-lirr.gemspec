# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "siriproxy-lirr"
  s.version     = "0.0.1" 
  s.authors     = ["parm289"]
  s.email       = [""]
  s.homepage    = ""
  s.summary     = %q{A Siri Proxy plugin that looks up LIRR times.}
  s.description = %q{A Siri Proxy plugin that looks up LIRR times.}

  s.rubyforge_project = "siriproxy-lirr"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency "mechanize"
  s.add_runtime_dependency "csv"
  s.add_runtime_dependency "time"
end
