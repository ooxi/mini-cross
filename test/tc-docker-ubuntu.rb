require 'pathname'
require 'test/unit'
require 'tmpdir'

require_relative '../src/docker-cli'
require_relative '../src/docker/ubuntu'
require_relative '../src/id'





class TestUbuntuDockerContext < Test::Unit::TestCase

	# Builds a minimal Ubuntu image
	def test_Smoke
		ubuntu = UbuntuDockerContext.new Id.real, 'ubuntu:16.04'
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

			output = `#{DockerCli.run_cmd Id.real, image, base_directory, command}`
			assert(output.include?(cookie), "Output should include cookie \`#{cookie}' but \`#{output}' does not")
			assert(output.include?('(__)\\       )\\/\\'), "Output should include cow but \`#{output}' does not")
		end	
	end
end

