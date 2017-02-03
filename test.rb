#!/usr/bin/env ruby

require 'psych'



yaml = <<EOF
---
install:
 - asf
 - b
 - c
---
apt-get -y update && apt-get -y install \
	deft

noch ein programm
EOF
puts yaml


Psych.load_stream(yaml) do |document|
	puts "new document"
	puts document
end

