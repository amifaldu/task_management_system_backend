# Use ARG for Ruby version consistency
ARG RUBY_VERSION=3.3.10
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# For development environment
ENV RAILS_ENV="development" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle"

# Install dependencies required for Ruby gem compilation
FROM base AS build

# Update apt package list and install dependencies
# Update apt package list and install dependencies 

RUN apt-get update -qq && apt-get install -y --no-install-recommends \ 
apt-transport-https \ 
ca-certificates \
 build-essential \ 
 libssl-dev \ 
 libreadline-dev \ 
 zlib1g-dev \ 
 libsqlite3-dev \ 
 libyaml-dev \ 
 libpq-dev \ 
 git \ 
 curl \ 
 libgmp-dev \ 
 && rm -rf /var/lib/apt/lists/*

# Fix permissions for /usr/local/bundle (necessary if you're using shared volumes)
RUN chown -R root:root /usr/local/bundle

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Uncomment below if you need Node.js for asset compilation
# Install node modules for asset compilation
# COPY package.json yarn.lock ./
# RUN yarn install --frozen-lockfile

# Copy application code
COPY . .

# Final stage for the app image
FROM base

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails /rails/db /rails/log /rails/storage /rails/tmp

USER 1000:1000

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start server via Thruster by default, this can be overwritten at runtime
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]