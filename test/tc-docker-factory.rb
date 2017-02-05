require 'test/unit'

require_relative '../src/docker/factory'
require_relative '../src/docker/fedora'
require_relative '../src/docker/ubuntu'



class TestDockerContextFactory < Test::Unit::TestCase


	def test_Fedora
		factory = DockerContextFactory.new Id.real
		fedora_23 = factory.from_specification 'fedora:23'
		assert(fedora_23.kind_of?(FedoraDockerContext), '`fedora:23\' should have led to FedoraDockerContext')
	end


	def test_Ubuntu
		factory = DockerContextFactory.new Id.real
		ubuntu_xenial = factory.from_specification 'ubuntu:16.04'
		assert(ubuntu_xenial.kind_of?(UbuntuDockerContext), '`ubuntu:16.04\' should have led to UbuntuDockerContext')
	end


	def test_Unsupported
		factory = DockerContextFactory.new Id.real
		factory.from_specification 'unsupported:os'
	rescue
		# Expected
	else
		assert(false, 'Unsupported specification should have raised an exception')
	end
end

