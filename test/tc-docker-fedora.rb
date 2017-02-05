require 'pathname'
require 'shellwords'
require 'test/unit'
require 'tmpdir'

require_relative '../src/docker-cli'
require_relative '../src/docker/fedora'
require_relative '../src/id'





class TestFedoraDockerContext < Test::Unit::TestCase

	# Builds a minimal Fedora image
	def test_Smoke
		fedora = FedoraDockerContext.new Id.real, 'fedora:25'
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

			output = `#{DockerCli.run_cmd Id.real, image, base_directory, command}`
			assert(output.include?(cookie), "Output should include cookie \`#{cookie}' but \`#{output}' does not")
			assert(output.include?('(__)\\       )\\/\\'), "Output should include cow but \`#{output}' does not")
		end

		`#{Shellwords.join ['docker', 'rmi', image]}`
	end
end

