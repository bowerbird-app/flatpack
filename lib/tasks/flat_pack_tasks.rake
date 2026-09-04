# frozen_string_literal: true

namespace :flat_pack do
  desc "Display FlatPack version"
  task :version do
    puts "FlatPack version: #{FlatPack::VERSION}"
  end

  desc "Print the FlatPack AI install contract JSON"
  task :contract do
    puts FlatPack::InstallContract.pretty_json
  end

  desc "Verify FlatPack installation in the current app"
  task verify_install: :environment do
    result = FlatPack::InstallVerifier.new.call

    puts "FlatPack installation verification"
    puts "Contract: #{FlatPack::InstallContract.path.relative_path_from(FlatPack::Engine.root)}"

    result.checks.each do |check|
      status_label = check.pass? ? "PASS" : "FAIL"
      puts "[#{status_label}] #{check.description}"
      puts "       #{check.details}"
    end

    next if result.success?

    abort "FlatPack installation verification failed. Run `bin/rails generate flat_pack:install` and compare your app with the AI install contract."
  end

  desc "Verify FlatPack CSS token references are defined"
  task audit_tokens: :environment do
    result = FlatPack::TokenAuditor.new.call

    puts "FlatPack token audit"
    puts "Defined: #{result.defined.size}"
    puts "Referenced: #{result.referenced.size}"

    if result.success?
      puts "PASS: every referenced token is defined in variables.css"
      next
    end

    puts "FAIL: missing token definitions:"
    result.missing.each { |token| puts "  #{token}" }
    abort "FlatPack token audit failed."
  end

  desc "Verify FlatPack kit classes use radius tokens instead of Tailwind scale names"
  task audit_radius_language: :environment do
    result = FlatPack::RadiusLanguageAuditor.new.call

    puts "FlatPack radius language audit"

    if result.success?
      puts "PASS: kit components and javascript use rounded-[var(--radius-*)]"
      next
    end

    puts "FAIL: leftover Tailwind radius scale utilities:"
    result.violations.each do |violation|
      puts "  #{violation.path}: #{violation.utilities.join(", ")}"
    end
    abort "FlatPack radius language audit failed."
  end

  desc "Display FlatPack information"
  task :info do
    puts "FlatPack UI Component Library"
    puts "Version: #{FlatPack::VERSION}"
    puts "Rails: #{Rails.version}"
    puts "Ruby: #{RUBY_VERSION}"
    puts "AI entrypoint: docs/ai/README.md"
    puts "AI install contract: docs/ai/install_contract.json"
    puts "\nComponents:"
    puts "  - Button (primary, secondary, ghost schemes)"
    puts "  - Table (with configurable columns)"
    puts "  - Icon (shared icon component)"
    puts "\nDocumentation: docs/"
    puts "Verification: bin/rake flat_pack:verify_install"
  end
end
