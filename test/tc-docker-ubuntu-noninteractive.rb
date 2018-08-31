# Copyright (c) 2018 github/ooxi
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
require 'shellwords'
require 'test/unit'
require 'tmpdir'

require_relative '../src/docker-cli'
require_relative '../src/docker/ubuntu'
require_relative '../src/id'





class TestNoninteractiveUbuntuDockerContext < Test::Unit::TestCase

	# Installing PHP on Ubuntu 18.04 causes tzdata to ask about your
	# geographic area which blocks installtion unless installation is done
	# in non interactive mode
	#
	# @see issue #15
	def test_Ubuntu_1804
		ubuntu = UbuntuDockerContext.new Id.real, 'ubuntu:18.04'

		ubuntu.install ['php']
		image = DockerCli.build_context ubuntu

		`#{Shellwords.join ['docker', 'rmi', image]}`

	end

end

