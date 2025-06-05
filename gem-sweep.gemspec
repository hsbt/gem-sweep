Gem::Specification.new do |spec|
  spec.name          = "gem-sweep"
  spec.version       = "0.2.0"
  spec.authors       = ["Hiroshi SHIBATA"]
  spec.email         = ["hsbt@ruby-lang.org"]

  spec.summary       = %q{Clean up unnecessary extension files for gem command.}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/hsbt/gem-sweep"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.licenses      = ["Ruby", "BSD-2-Clause"]
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.files         = ["lib/rubygems_plugin.rb", "lib/rubygems/commands/sweep_command.rb"]
  spec.require_paths = ["lib"]
end
