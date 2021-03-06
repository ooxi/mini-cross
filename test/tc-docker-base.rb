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

require 'test/unit'
require 'tmpdir'

require_relative '../src/docker/base'
require_relative '../src/docker/docker-run-arguments'
require_relative '../src/docker/dockerfile'





class TestBaseDockerContext < Test::Unit::TestCase

	def test_Initialize
		context = MockDockerContext.new
		assert(context.kind_of?(BaseDockerContext), 'Expected context to be of type `BaseDockerContext\'')

		dockerfile = context.instance_variable_get('@dockerfile')
		assert(dockerfile.kind_of?(MockDockerfile), "Unexpected dockerfile \`#{dockerfile}'")
	end



	def test_Copy
		context = MockDockerContext.new

		Dir.mktmpdir do |dir|
			source = Pathname.new dir

			sources_before = context.instance_variable_get('@sources')
			assert(sources_before.empty?, 'Expected sources to be empty before initial copy')

			context.copy source
			sources_after = context.instance_variable_get('@sources')
			assert_equal(1, sources_after.size, 'Unexpected size of sources after first copy')
			assert_equal(source, sources_after[0], 'Unexpected content of sources')
		end
	end



	def test_InstallNoOverwrite
		dc = BaseDockerContext.new MockDockerfile.new, MockDockerRunArguments.new
		dc.install
	rescue
		# Expected
	else
		assert(false, 'Expected exception to be raised, when calling `install\' of base class')
	end



	def test_InstallOverwrite
		dc = MockDockerContext.new
		assert_equal('61fd08d7-36a2-4468-988e-91a39fc17bd8', dc.install(['test-package']), 'Unexpected result of overwritten `install\' method')
	end



	def test_WriteToSimple
		dc = BaseDockerContext.new MockDockerfile.new, MockDockerRunArguments.new

		Dir.mktmpdir do |dir|
			directory = Pathname.new dir
			dc.write_to directory

			dockerfile = directory + 'Dockerfile'
			assert(dockerfile.file?, "Expected Dockerfile at #{dockerfile}")
			assert_equal('my docker file', File.read(dockerfile), 'Unexpected dockerfile contents')
		end
	end



	def test_WriteToExtended
		dc = BaseDockerContext.new MockDockerfile.new, MockDockerRunArguments.new

		Dir.mktmpdir do |dir|
			source = Pathname.new dir

			File.write(source + 'test file', 'test content')
			dc.copy(source)

			Dir.mktmpdir do |dir|
				directory = Pathname.new dir
				dc.write_to directory

				dockerfile = directory + 'Dockerfile'
				first_source = directory + '0'
				test_file = first_source + 'test file'

				assert(dockerfile.file?, "Expected Dockerfile at #{dockerfile}")
				assert(first_source.directory?, "Expected source directory at #{first_source}")
				assert(test_file.file?, "Expected test file at #{test_file}")
				assert_equal('test content', File.read(test_file), "Unexpected test file content")
			end
		end
	end
end





# Required as argument to BaseDockerContext::initialize
class MockDockerfile < Dockerfile

	def to_s
		return 'my docker file'
	end
end



# Required as argument to BaseDockerContext::initialize
class MockDockerRunArguments < DockerRunArguments

	def to_args
		return []
	end
end



# Required to ensure correct behaviour of overwritten method
class MockDockerContext < BaseDockerContext

	def initialize
		super MockDockerfile.new, MockDockerRunArguments.new
	end

	def install(package)
		return '61fd08d7-36a2-4468-988e-91a39fc17bd8'
	end
end

