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
require_relative '../src/docker/fedora'
require_relative '../src/id'





class TestFedoraDockerContext < Test::Unit::TestCase

	# Builds a minimal Fedora image
	def execute_smoke_test(version)
		fedora = FedoraDockerContext.new Id.real, version
		fedora.install ['cowsay']


		# Build Fedora image
		cookie = '0bd82167-021e-4e9a-b2f1-0dd44b56a671'
		image = nil

		Dir.mktmpdir do |dir|
			directory = Pathname.new dir

			file = directory + 'cowsay.sh'
			File.write(file, "#!/usr/bin/cowsay #{cookie}")
			File.chmod(0777, file)

			fedora.copy directory
			image = DockerCli.build_context fedora
		end

		assert_not_nil(image, 'Invalid docker image identification')


		# Run Fedora container
		Dir.mktmpdir do |dir|
			base_directory = Pathname.new dir
			command = ['/cowsay.sh']

			output = `#{DockerCli.run_cmd image, fedora.run, false, command}`
			assert(output.include?(cookie), "Output should include cookie \`#{cookie}' but \`#{output}' does not")
			assert(output.include?('(__)\\       )\\/\\'), "Output should include cow but \`#{output}' does not")
		end

		`#{Shellwords.join ['docker', 'rmi', image]}`
	end





	# Seems to work, but cowsay is broken: Can't locate Encode.pm in @INC
	# (you may need to install the Encode module)
#	def test_Fedora_24
#		self.execute_smoke_test 'fedora:24'
#	end

	def test_Fedora_25
		self.execute_smoke_test 'fedora:25'
	end

	def test_Fedora_26
		self.execute_smoke_test 'fedora:26'
	end

	def test_Fedora_27
		self.execute_smoke_test 'fedora:27'
	end

	def test_Fedora_28
		self.execute_smoke_test 'fedora:28'
	end

	def test_Fedora_29
		self.execute_smoke_test 'fedora:29'
	end

	def test_Fedora_30
		self.execute_smoke_test 'fedora:30'
	end

	def test_Fedora_31
		self.execute_smoke_test 'fedora:31'
	end

	def test_Fedora_32
		self.execute_smoke_test 'fedora:32'
	end

	def test_Fedora_33
		self.execute_smoke_test 'fedora:33'
	end

	def test_Fedora_34
		self.execute_smoke_test 'fedora:34'
	end

	def test_Fedora_Rawhide
		self.execute_smoke_test 'fedora:rawhide'
	end
end

