require 'pathname'
require 'test/unit'
require 'tmpdir'

require_relative '../src/find-configuration'
require_relative '../src/yaml/configuration-parser'
require_relative '../src/yaml/instruction'



class TestYamlConfigurationParser < Test::Unit::TestCase


	# Smoke
	def test_Smoke
		Dir.mktmpdir do |dir|
			directory = Pathname.new dir

			File.write(directory + 'mc.yaml', '
---
base: ubuntu:16.04
---
#!/bin/bash

echo Test
			')

			configuration = FindConfiguration.without_name directory
			instructions = YamlConfigurationParser.parse configuration

			assert_not_nil(instructions, '`instructions\' must not be nil')
			assert(instructions.kind_of?(YamlInstruction), '`instructions\' should have been of type YamlInstruction')
			assert_equal('ubuntu:16.04', instructions.base, 'Unexpected base')
		end
	end

end

