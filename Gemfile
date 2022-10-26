# frozen_string_literal: true

source "https://rubygems.org"

# Bundler could not find compatible versions for gem "rack":
#   as standalone_migrations 7.1.0 is using railties 7.0.4 and that cannot go
#   above ~> 2.0
# Which meant we dropped to rack 2.2.4, needed a server like puma and no longer
# needed the separate rack-sessions
# gem "rackup", "~> 0.2.2"
# gem "rack-session", "~> 0.3.0"
gem "puma", "~> 6.0"
gem "rack", "~> 2.2.4"
gem "sidekiq", "= 7.0.0.beta1"

gem "filewatcher", "~> 2.0"
gem "standard", "~> 1.16"
gem "zeitwerk", "~> 2.6"

gem "activerecord", "~> 7.0"
gem "pg", "~> 1.4"
gem "standalone_migrations", "~> 7.1.0"
# force the version of railties as the default one found by bundler is way old
# and this one works
# standalone_migrations (~> 7.1.0) was resolved to 7.1.0, which depends on
#       railties (>= 4.2.7, < 7.1.0, != 5.2.3, != 5.2.3.rc1) was resolved to 4.2.8.rc1
gem "railties", "~> 7.0.4"

# bundle exec que
# Unsupported logging level: info (try debug, info, warn, error, or fatal)
# gem "que", "~> 2.2.0" # does not work with que-web 0.9.4
gem "que", "~> 1.4"
gem "que-scheduler", "~> 4.4"
gem "que-web", "~> 0.9.4"
