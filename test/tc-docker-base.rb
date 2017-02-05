require 'test/unit'
require 'tmpdir'

require_relative '../src/docker/base'





class TestBaseDockerContext < Test::Unit::TestCase

	def test_Initialize
		context = MockDockerContext.new 'my docker file'
		assert(context.kind_of?(BaseDockerContext), 'Expected context to be of type `BaseDockerContext\'')

		dockerfile = context.instance_variable_get('@dockerfile')
		assert_equal('my docker file', dockerfile, 'Unexpected docker file content')
	end



	def test_Copy
		context = MockDockerContext.new 'my docker file'

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
		dc = BaseDockerContext.new 'my docker file'
		dc.install
	rescue
		# Expected
	else
		assert(false, 'Expected exception to be raised, when calling `install\' of base class')
	end



	def test_InstallOverwrite
		dc = MockDockerContext.new 'my docker file'
		assert_equal('61fd08d7-36a2-4468-988e-91a39fc17bd8', dc.install(['test-package']), 'Unexpected result of overwritten `install\' method')
	end



	def test_WriteToSimple
		dc = BaseDockerContext.new 'my docker file'

		Dir.mktmpdir do |dir|
			directory = Pathname.new dir
			dc.write_to directory

			dockerfile = directory + 'Dockerfile'
			assert(dockerfile.file?, "Expected Dockerfile at #{dockerfile}")
			assert_equal('my docker file', File.read(dockerfile), 'Unexpected dockerfile contents')
		end
	end



	def test_WriteToExtended
		dc = BaseDockerContext.new 'my docker file'

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





# Required to ensure correct behaviour of overwritten method
class MockDockerContext < BaseDockerContext

	def install(package)
		return '61fd08d7-36a2-4468-988e-91a39fc17bd8'
	end
end

