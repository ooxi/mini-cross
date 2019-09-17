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

require_relative '../src/docker/factory'
require_relative '../src/find-configuration'
require_relative '../src/yaml/configuration-parser'
require_relative '../src/yaml/instruction'
require_relative '../src/yaml/run-instruction'
require_relative '../src/id'



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

			# YamlCollectionInstruction
			#  - YamlCollectionInstruction
			#     - YamlBaseInstruction
			#     - YamlRunInstruction
			configuration = FindConfiguration.without_name directory
			instructions = YamlConfigurationParser.parse configuration

			collected_instructions = instructions.instance_variable_get("@instructions")
			assert(collected_instructions.kind_of?(Array), 'Test assertion error, expected array of instructions inside YamlCollectionInstruction')
			assert_equal(1, collected_instructions.length, 'Expected exactly one instruction in outer collection')

			assert(collected_instructions[0].kind_of?(YamlCollectionInstruction), "Expected first instruction in outer collection to be a YamlCollectionInstruction but is #{collected_instructions[0]}")

			collected_instructions = collected_instructions[0].instance_variable_get("@instructions")
			assert(collected_instructions.kind_of?(Array), 'Test assertion error, expected array of instructions inside YamlCollectionInstruction')
			assert_equal(2, collected_instructions.length, 'Expected exactly one instruction in inner collection')

			run_instruction = collected_instructions[1]
			assert(run_instruction.kind_of?(YamlRunInstruction), "Expected second instruction to be a YamlRunInstruction but is \`#{run_instruction}'")

			script = run_instruction.instance_variable_get("@script")
			assert(script.kind_of?(String), "Expected @script to be of kind String but is \`#{script}'")

			assert_equal("#!/bin/bash\n\nline_one\n./line_two\n人物", script, 'Wrong script')
		end
	end





	# YamlPublishInstruction
	def test_ParsePublish
		Dir.mktmpdir do |dir|
			directory = Pathname.new dir

			File.write(directory + 'mc.yaml', '
---
base: ubuntu:16.04
publish:
 - 8080:80
---
')

			configuration = FindConfiguration.without_name directory
			instructions = YamlConfigurationParser.parse configuration

			# YamlCollectionInstruction
			#  - YamlCollectionInstruction
			#     - YamlBaseInstruction
			#     - YamlPublishInstruction
			#  - YamlRunInstruction
			collected_instructions = instructions.instance_variable_get("@instructions")
			assert(collected_instructions.kind_of?(Array), 'Test assertion error, expected array of instructions inside YamlCollectionInstruction')
			assert_equal(1, collected_instructions.length, 'Expected exactly one instruction in outer collection')

			assert(collected_instructions[0].kind_of?(YamlCollectionInstruction), "Expected first instruction in outer collection to be a YamlCollectionInstruction but is #{collected_instructions[0]}")
			collected_instructions = collected_instructions[0].instance_variable_get("@instructions")

			publish_instruction = collected_instructions[0].instance_variable_get('@instructions')[1]
			assert(publish_instruction.kind_of?(YamlPublishInstruction), "Expected second instruction to be a YamlPublishInstruction but is \`#{publish_instruction}'")

			publications = publish_instruction.instance_variable_get('@publications')
			assert(publications.kind_of?(Array), "Expected @publications to be of kind Array but is \`#{publications}'")

			assert_equal(1, publications.length, 'Expected exactly one publication')
			assert_equal(nil, publications[0].ip, 'Wrong ip of publication')
			assert_equal(8080, publications[0].host_port, 'Wrong host port of publication')
			assert_equal(80, publications[0].container_port, 'Wrong container port of publication')


			# Create docker container as kind of smoke test
			context_factory = DockerContextFactory.new Id.real

			context = context_factory.from_specification instructions.base
			instructions.apply_to context

			dr = context.run
			dr_publications = dr.instance_variable_get('@publications')

			assert(dr_publications.kind_of?(Array), "Expected @publications of DockerRunArguments to be of kind Array but is \`#{dr_publications}'")
			assert_equal(1, dr_publications.length, 'Expected exactly one DockerRunArguments publication')
			assert_equal(['-p', '8080:80'], dr_publications[0].to_args, 'Wrong publication')
		end
	end





	# YamlMixinInstruction
	#
	# By using mixins we can share common behaviour. The test case defines
	# a hierarchy looking like this:
	#
	# ---
	# mc
	#  - common
	#  - dep-a
	#     - common
	#     - dep-b
	# ---
	#
	# We expect the reference to {@code common} to be dropped from
	# {@code dep-a} automatically since it was already referenced by
	# {@code mc} resulting in an instruction tree with only one reference
	# to common.
	def test_ParseMixin
		Dir.mktmpdir do |dir|
			directory = Pathname.new dir

			File.write(directory + 'mc.yaml', '
---
base: ubuntu:16.04
install:
 - base-0
 - base-1
mixin:
 - common
 - dep-a
publish:
 - 8080:80
---
#!/bin/bash

mc
')

			# @warning Mixins should not define a base themself!
			#     This test contains a base inside a mixin in order
			#     to ensure a well defined behaviour even in that
			#     case
			File.write(directory + 'common.yaml', '
---
base: ubuntu:18.04
install:
 - common-0
publish:
 - 9090:90
 - 9091:91
---
#!/bin/bash

common
')

			# @warning Both {@code mc.yaml} as well as {@dep-a.yaml}
			#     reference {@code common.yaml} as mixin.
			#
			#     Since the reference to {@code common.yaml} from
			#     {@code mc.yaml} comes first, this reference does
			#
			File.write(directory + 'dep-a.yaml', '
---
install:
 - dep-a-0
 - dep-a-1
mixin:
 - common
 - dep-b
publish:
 - 7070:70
---
#!/bin/bash

dep-a
')

			File.write(directory + 'dep-b.yaml', '
---
install:
 - dep-b-0
 - dep-b-1
publish:
 - 6060:60
---
#!/bin/bash

dep-b
')

			configuration = FindConfiguration.without_name directory
			actual = YamlConfigurationParser.parse configuration


			expected =
				[YamlConfigurationCollectionInstruction,								# mc
				[	[YamlFileCollectionInstruction,									# mc
					[	[YamlFrontMatterCollectionInstruction,							# mc
						[	YamlBaseInstruction,								# mc
							YamlInstallInstruction,								# mc
							[YamlMixinCollectionInstruction,						# mc
							[	[YamlFileCollectionInstruction,						# common
								[	[YamlFrontMatterCollectionInstruction,				# common
									[	YamlBaseInstruction,					# common
										YamlInstallInstruction,					# common
										YamlPublishInstruction,					# common
									]],
									YamlRunInstruction,						# common
								]],
								[YamlFileCollectionInstruction,						# dep-a
								[	[YamlFrontMatterCollectionInstruction,				# dep-a
									[	YamlInstallInstruction,					# dep-a
										[YamlMixinCollectionInstruction,			# dep-a
										[	YamlNopInstruction,				# common (removed)
											[YamlFileCollectionInstruction,			# dep-b
											[	[YamlFrontMatterCollectionInstruction,	# dep-b
												[	YamlInstallInstruction,		# dep-b
													YamlPublishInstruction,		# dep-b
												]],
												YamlRunInstruction,			# dep-b
											]],
										]],
										YamlPublishInstruction,					# dep-a
									]],
									YamlRunInstruction,						# dep-a
								]],
							]],
							YamlPublishInstruction,								# mc
						]],
						YamlRunInstruction,									# mc
					]],
				]]


			# In order to make the test simpler, we only check the
			# type of instructions, not their actual content
			assert_instruction_equal(expected, actual)
		end
	end



	def assert_instruction_equal(expected, actual)

		# If not an array, a type is to be compared
		if !expected.kind_of?(Array)
			assert(actual.kind_of?(expected), "Expected #{actual} to be of type #{expected}")
			return
		end

		# If an array is expected, the first element is the collection
		# type while the second is the expected number of instructions
		assert_equal(2, expected.length, 'Test setup error')
		expected_collection_type = expected[0]
		expected_instructions = expected[1]


		# Check collection type
		assert(actual.kind_of?(expected_collection_type), "Expected #{actual} to be of type #{expected_collection_type}")


		# Check instruction list metadata
		actual_instructions = actual.instance_variable_get("@instructions")
		assert(actual_instructions.kind_of?(Array), 'Test setup error')
		assert_equal(expected_instructions.length, actual_instructions.length, 'Unexpected number of instructions in collection')


		# Check individual instructions
		actual_instructions.each_with_index do |instruction, index|
			assert_instruction_equal(expected_instructions[index], instruction)
		end
	end
end

