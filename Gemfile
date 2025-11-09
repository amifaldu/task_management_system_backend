source "https://rubygems.org"

# Use stable Rails release (edge version available via GitHub if needed)
gem "rails", "~> 8.1.1"

# Lightweight, file-based database for development and testing
gem "sqlite3", ">= 2.1"

# Fast, concurrent web server optimized for Ruby/Rails
gem "puma", ">= 5.0"

# Optional: Build JSON APIs easily (commented out for now)
# gem "jbuilder"

# Optional: Secure password handling via ActiveModel (commented out for now)
# gem "bcrypt", "~> 3.1.7"

# Required for Windows and JRuby platforms to support time zones
gem "tzinfo-data", platforms: %i[windows jruby]

# Database-backed adapters for caching, background jobs, and WebSockets
gem "solid_cache"   # Rails.cache
gem "solid_queue"   # Active Job
gem "solid_cable"   # Action Cable

# Speeds up boot time by caching expensive operations
gem "bootsnap", require: false

# Container deployment tool for Rails apps (formerly MRSK)
gem "kamal", require: false

# Adds HTTP caching, compression, and X-Sendfile support to Puma
gem "thruster", require: false

# Enables image transformations for Active Storage
gem "image_processing", "~> 1.2"

# Optional: Handle CORS for APIs (commented out for now)
# gem "rack-cors"

# Thread-safe concurrency primitives (used for in-memory task storage)
gem "concurrent-ruby"

# Interactive debugging tool — use `binding.pry` to inspect runtime state
gem "pry"

# GraphQL framework for Ruby — enables GraphQL API support
gem "graphql"

group :development, :test do
  # Debugging tool for Ruby and Rails (MRI and Windows only)
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  # Core RSpec testing framework
  gem 'rspec-rails'
  # Security audit tool for gem dependencies
  gem "bundler-audit", require: false

  # Static analysis tool for detecting security vulnerabilities in Rails apps
  gem "brakeman", require: false

  # Opinionated RuboCop rules for idiomatic Rails code
  gem "rubocop-rails-omakase", require: false

  # Web interface for testing GraphQL queries and mutations
  gem "graphiql-rails"
end