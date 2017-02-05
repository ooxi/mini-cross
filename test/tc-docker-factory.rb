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

