#!/usr/bin/env bash
set -eux

echo "Activating rbenv..."

eval "$(~/.rbenv/bin/rbenv init - bash)"

bundle exec ruby server.rb
