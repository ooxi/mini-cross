require 'test/unit'

require_relative '../src/docker-context'





class TestDockerContext < Test::Unit::TestCase


	# Context directory must be created by `initialized' and destroyed by
	# `close'
	def test_CreateAndDestroy
		dc = DockerContext.new
		directory = dc.instance_variable_get('@directory')

		assert(File.directory?(directory), "Directory #{directory} must exist")
	ensure
		if dc
			dc.close
			assert(!File.directory?(directory), "Directory #{directory} must no longer exist")
		end
	end


	def test_BuildImage
		dc = DockerContext.new
		puts dc.build_image

	ensure
		dc.close if dc
	end

end

