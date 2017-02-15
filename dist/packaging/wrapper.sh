#!/bin/bash
set -e

# Figure out where this script is located.
#
# @see https://unix.stackexchange.com/a/17500/86003
SELFDIR="$(dirname "$(readlink -f "$0")")"

# Tell Bundler where the Gemfile and gems are.
export BUNDLE_GEMFILE="$SELFDIR/lib/vendor/Gemfile"
unset BUNDLE_IGNORE_CONFIG

# Run the actual app using the bundled Ruby interpreter, with Bundler activated.
#
# @see https://stackoverflow.com/a/1537695/2534648
exec "$SELFDIR/lib/ruby/bin/ruby" -rbundler/setup "$SELFDIR/lib/app/bin/mini-cross.rb" "$@"

