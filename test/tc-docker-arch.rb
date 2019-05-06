# Copyright (c) 2019 github/ooxi
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
require_relative '../src/docker/arch'
require_relative '../src/id'





class TestArchDockerContext < Test::Unit::TestCase

	# Builds a minimal Arch Linux image
	def execute_smoke_test(version)
		arch = ArchDockerContext.new Id.real, version
		arch.install ['cowsay']


		# Build Arch Linux image
		cookie = '0bd82167-021e-4e9a-b2f1-0dd44b56a671'
		image = nil

		Dir.mktmpdir do |dir|
			directory = Pathname.new dir

			file = directory + 'cowsay.sh'
			File.write(file, "#!/usr/bin/cowsay #{cookie}")
			File.chmod(0777, file)

			arch.copy directory
			image = DockerCli.build_context arch
		end

		assert_not_nil(image, 'Invalid docker image identification')


		# Run Arch Linux container
		Dir.mktmpdir do |dir|
			base_directory = Pathname.new dir
			command = ['/cowsay.sh']

			output = `#{DockerCli.run_cmd image, arch.run, command}`
			assert(output.include?(cookie), "Output should include cookie \`#{cookie}' but \`#{output}' does not")
			assert(output.include?('(__)\\       )\\/\\'), "Output should include cow but \`#{output}' does not")
		end

		`#{Shellwords.join ['docker', 'rmi', image]}`
	end





	def test_Arch_Base
		self.execute_smoke_test 'archlinux/base'
	end
end

