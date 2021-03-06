# -*- encoding: utf-8 -*-
require File.expand_path("../lib/triangular/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "triangular"
  s.version     = Triangular::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Aaron Gough", "Zhi-Qiang Lei"]
  s.email       = ["aaron@aarongough.com", "zhiqiang.lei@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/triangular"
  s.summary     = "[ALPHA] A simple Ruby library for reading, writing, and manipulating Stereolithography (STL) files."
  s.description = "Triangular is an easy-to-use Ruby library for reading, writing and manipulating Stereolithography (STL) files.\n\n The main purpose of Triangular is to enable its users to quickly create new software for Rapid Prototyping and Personal Manufacturing applications. "

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "triangular"

  s.add_dependency 'thor'
  s.add_dependency 'ptools'
  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rspec", "~> 3"
  s.add_development_dependency "pry"
  s.add_development_dependency "aruba"
  s.add_development_dependency "cucumber"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
