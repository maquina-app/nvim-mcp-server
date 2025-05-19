# frozen_string_literal: true

require_relative "lib/nvim-mcp-server/version"

Gem::Specification.new do |spec|
  spec.name = "nvim-mcp-server"
  spec.version = NvimMcpServer::VERSION
  spec.authors = ["Mario Alberto Chávez"]
  spec.email = ["mario.chavez@gmail.com"]

  spec.summary = "MCP server for Neovim"
  spec.description = "A Ruby implementation of the MCP server protocol for Neovim"
  spec.homepage = "https://github.com/maquina-app/nvim-mcp-server"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.each_line("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "fast-mcp", "~> 1.1.0"
  spec.add_dependency "rack", "~> 3.1.12"
  spec.add_dependency "puma", "~> 6.6.0"
  spec.add_dependency "logger", "~> 1.6.6"
  spec.add_dependency "neovim", "~> 0.10.0"
  spec.add_development_dependency "standard"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
