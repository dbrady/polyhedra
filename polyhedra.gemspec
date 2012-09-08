# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "polyhedra/version"

Gem::Specification.new do |s|
  s.name        = "polyhedra"
  s.version     = Polyhedra::VERSION
  s.authors     = ["David Brady"]
  s.email       = ["github@shinybit.com"]
  s.homepage    = ""
  s.summary     = %q{Dice manipulation and rolling gem capable of handling complex dice expressions}
  s.description = %q{Dice manipulation and rolling gem capable of handling complex RPG dice expressions, from a simple "d6" up to "4d6r1k3-2x10 frost" and "3d6", etc.}

  s.rubyforge_project = "polyhedra"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:

#  s.add_runtime_dependency "treetop"
end
