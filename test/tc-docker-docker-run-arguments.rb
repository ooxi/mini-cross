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

require_relative 'mock-id'
require_relative '../src/docker/docker-run-arguments'





class TestDockerfile < Test::Unit::TestCase


	# Integration
	def test_DockerRunArguments
		run = DockerRunArguments.new

		run.user (MockId.new '1', 'my-user', '2', 'my-group')
		run.add_volume (Pathname.new '/src'), (Pathname.new '/dest'), []
		run.workdir (Pathname.new '/wd')

		args = run.to_args
		assert_equal(['-u', '1:2', '-v', '/src:/dest', '-w', '/wd'], args, 'Wrong docker run arguments')
	end


	def test_DockerPublishArgument_IpHostContainer
		publication = DockerPublishArgument.new '127.0.0.1', 8080, 80
		args = publication.to_args

		assert_equal(['-p', '127.0.0.1:8080:80'], args, 'Wrong docker publish arguments')
	end


	def test_DockerPublishArgument_IpContainer
		publication = DockerPublishArgument.new '127.0.0.1', nil, 80
		args = publication.to_args

		assert_equal(['-p', '127.0.0.1::80'], args, 'Wrong docker publish arguments')
	end


	def test_DockerPublishArgument_HostContainer
		publication = DockerPublishArgument.new nil, 8080, 80
		args = publication.to_args

		assert_equal(['-p', '8080:80'], args, 'Wrong docker publish arguments')
	end


	def test_DockerPublishArgument_Container
		publication = DockerPublishArgument.new nil, nil, 80
		args = publication.to_args

		assert_equal(['-p', '80'], args, 'Wrong docker publish arguments')
	end


	def test_DockerUserArgument_NoUser
		user = DockerUserArgument.new nil
		args = user.to_args

		assert_equal([], args, 'Wrong docker user arguments')
	end


	def test_DockerUserArgument_WithUser
		id = MockId.new '1010', 'my-user', '2020', 'my-group'

		user = DockerUserArgument.new id
		args = user.to_args

		assert_equal(['-u', '1010:2020'], args, 'Wrong docker user arguments')
	end


	def test_DockerVolumeArgument_NoOptions
		host_source = Pathname.new '/host/user name/'
		container_destination = Pathname.new '/container/user name/'
		options = []

		volume = DockerVolumeArgument.new host_source, container_destination, options
		args = volume.to_args

		assert_equal(['-v', '/host/user\\ name/:/container/user\\ name/'], args, 'Wrong docker volume arguments')
	end


	def test_DockerVolumeArgument_WithOptions
		host_source = Pathname.new '/host/user name/'
		container_destination = Pathname.new '/container/user name/'
		options = ['ro', 'slave']

		volume = DockerVolumeArgument.new host_source, container_destination, options
		args = volume.to_args

		assert_equal(['-v', '/host/user\\ name/:/container/user\\ name/:ro,slave'], args, 'Wrong docker volume arguments')
	end


	def test_DockerWorkdirArgument_NoWorkdir
		directory = nil

		workdir = DockerWorkdirArgument.new directory
		args = workdir.to_args

		assert_equal([], args, 'Wrong docker workdir arguments')
	end


	def test_DockerWorkdirArgument_WithWorkdir
		directory = Pathname.new '/home/user name/'

		workdir = DockerWorkdirArgument.new directory
		args = workdir.to_args

		assert_equal(['-w', '/home/user\\ name/'], args, 'Wrong docker workdir arguments')
	end
end

