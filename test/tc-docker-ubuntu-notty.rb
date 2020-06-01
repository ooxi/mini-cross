# Copyright (c) 2020 github/ooxi
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





class TestNoTtyUbuntuDockerContext < Test::Unit::TestCase

	# Running mini-cross in a CI environment without full TTY support fails,
	# unless the `--no-tty` argument is passed to mini-cross
	def testNoTty
		ubuntu = UbuntuDockerContext.new Id.real, 'ubuntu:20.04'
		ubuntu.install ['cowsay']


		# Build Ubuntu image
		cookie = '6fedaae0-4787-4272-b8a6-03d1463ad08b'
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

			# @see https://superuser.com/a/1430883
			tty = false
			output = `true | #{DockerCli.run_cmd image, ubuntu.run, tty, command}`

			assert(output.include?(cookie), "Output should include cookie \`#{cookie}' but \`#{output}' does not")
			assert(output.include?('(__)\\       )\\/\\'), "Output should include cow but \`#{output}' does not")
		end

		`#{Shellwords.join ['docker', 'rmi', image]}`
	end

end

