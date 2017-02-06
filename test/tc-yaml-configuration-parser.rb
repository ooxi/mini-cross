# Copyright (c) 2017 github/ooxi
#     https://github.com/ooxi/mini-cross
#
# This software is provided 'as-is', without any express or implied warranty. In
# no event will the authors be held liable for any damages arising from the use
# of this software.
#
# Permission is granted to anyone to use this software for any purpose,
# including commercial applications, and to alter it and redistribute it freely,
# subject to the following restrictions:
#
#  1. The origin of this software must not be misrepresented; you must not claim
#     that you wrote the original software. If you use this software in a product,
#     an acknowledgment in the product documentation would be appreciated but is
#     not required.
#
#  2. Altered source versions must be plainly marked as such, and must not be
#     misrepresented as being the original software.
#
#  3. This notice may not be removed or altered from any source distribution.

require 'pathname'
require 'test/unit'
require 'tmpdir'

require_relative '../src/find-configuration'
require_relative '../src/yaml/configuration-parser'
require_relative '../src/yaml/instruction'
require_relative '../src/yaml/run-instruction'



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





	# YamlRunInstruction
	def test_ParseRun
		Dir.mktmpdir do |dir|
			directory = Pathname.new dir

			File.write(directory + 'mc.yaml', '
---
base: ubuntu:16.04
---
#!/bin/bash

line_one
./line_two
人物')

			configuration = FindConfiguration.without_name directory
			instructions = YamlConfigurationParser.parse configuration

			collected_instructions = instructions.instance_variable_get("@instructions")
			assert(collected_instructions.kind_of?(Array), 'Test assertion error, expected array of instructions inside YamlCollectionInstruction')

			run_instruction = collected_instructions[1]
			assert(run_instruction.kind_of?(YamlRunInstruction), "Expected second instruction to be a YamlRunInstruction but is \`#{run_instruction}'")

			script = run_instruction.instance_variable_get("@script")
			assert(script.kind_of?(String), "Expected @script to be of kind String but is \`#{script}'")

			assert_equal("#!/bin/bash\n\nline_one\n./line_two\n人物", script, 'Wrong script')
		end
	end

end

