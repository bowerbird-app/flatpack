require_relative "lib/flat_pack/version"

Gem::Specification.new do |spec|
  spec.name        = "flat_pack"
  spec.version     = FlatPack::VERSION
  spec.authors     = ["FlatPack Team"]
  spec.email       = ["team@flatpack.dev"]
  spec.homepage    = "https://github.com/flatpack/flat_pack"
  spec.summary     = "A modern Rails 8 UI component library"
  spec.description = "FlatPack is a production-grade Rails 8 Engine providing a comprehensive UI component library built with ViewComponent, Tailwind CSS 4, and modern Rails conventions."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,lib,docs}/**/*", "MIT-LICENSE", "Rakefile", "README.md", "CHANGELOG.md"]
  end

  spec.required_ruby_version = ">= 3.2.0"

  # Core dependencies
  spec.add_dependency "rails", "~> 8.0"
  spec.add_dependency "view_component", "~> 3.0"
  spec.add_dependency "tailwind_merge", "~> 0.13"

  # Development dependencies
  spec.add_development_dependency "sqlite3", "~> 2.0"
  spec.add_development_dependency "standard", "~> 1.35"
  spec.add_development_dependency "propshaft", "~> 1.0"
end
