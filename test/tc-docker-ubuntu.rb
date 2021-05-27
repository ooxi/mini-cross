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
require 'shellwords'
require 'test/unit'
require 'tmpdir'

require_relative '../src/docker-cli'
require_relative '../src/docker/ubuntu'
require_relative '../src/id'





class TestUbuntuDockerContext < Test::Unit::TestCase

	# Builds a minimal Ubuntu image
	def execute_smoke_test(version)
		ubuntu = UbuntuDockerContext.new Id.real, version
		ubuntu.install ['cowsay']


		# Build Ubuntu image
		cookie = 'f53fc196-fcf6-45ae-add9-3a6ab914189d'
		image = nil

		Dir.mktmpdir do |dir|
			directory = Pathname.new dir

			file = directory + 'cowsay.sh'
			File.write(file, "#!/usr/games/cowsay #{cookie}")
			File.chmod(0777, file)

			ubuntu.copy directory
			image = DockerCli.build_context ubuntu
		end

		assert_not_nil(image, 'Invalid docker image identification')


		# Run Ubuntu container
		Dir.mktmpdir do |dir|
			base_directory = Pathname.new dir
			command = ['/cowsay.sh']

			output = `#{DockerCli.run_cmd image, ubuntu.run, true, command}`
			assert(output.include?(cookie), "Output should include cookie \`#{cookie}' but \`#{output}' does not")
			assert(output.include?('(__)\\       )\\/\\'), "Output should include cow but \`#{output}' does not")
		end

		`#{Shellwords.join ['docker', 'rmi', image]}`
	end





	def test_Ubuntu_1404
		self.execute_smoke_test 'ubuntu:14.04'
	end

	def test_Ubuntu_1604
		self.execute_smoke_test 'ubuntu:16.04'
	end

	def test_Ubuntu_1804
		self.execute_smoke_test 'ubuntu:18.04'
	end

	def test_Ubuntu_2004
		self.execute_smoke_test 'ubuntu:20.04'
	end

	def test_Ubuntu_2010
		self.execute_smoke_test 'ubuntu:20.10'
	end

	def test_Ubuntu_2104
		self.execute_smoke_test 'ubuntu:21.04'
	end
end

