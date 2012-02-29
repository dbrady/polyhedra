# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "dicebag/version"

Gem::Specification.new do |s|
  s.name        = "dicebag"
  s.version     = Dicebag::VERSION
  s.authors     = ["David Brady"]
  s.email       = ["github@shinybit.com"]
  s.homepage    = ""
  s.summary     = %q{Dice manipulation and rolling gem capable of handling complex dice expressions}
  s.description = %q{Dice manipulation and rolling gem capable of handling complex RPG dice expressions, such as "3d6x10+2d4x10" and "3d6, reroll 1's", etc.}

  s.rubyforge_project = "dicebag"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"

  # s.add_runtime_dependency "rest-client"
end
