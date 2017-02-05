require 'digest'
require 'pathname'
require 'shellwords'
require 'tmpdir'

require_relative 'docker/base'
require_relative 'shell'



# Helper around the docker command line interface.
#
# TODO: Replace with docker API client like swipely/docker-api
#
# @see https://github.com/swipely/docker-api
class DockerCli


	# Build the docker context located at the provided directory
	#
	# @param directory Directory to be used as docker context
	# @return Docker image identification
	def self.build(directory)
		directory = Pathname.new directory


		# Sanity check
		dockerfile = directory + 'Dockerfile'
		raise "Expected Dockerfile at #{dockerfile}" unless dockerfile.file?

		hash = Digest::SHA256.file dockerfile
		image_tag = 'mini-cross-' + hash.hexdigest


		# Build docker image with temporary tag
		Shell.run Shellwords.join([
			'docker',
			'build',
# TODO: Enable as soon as Docker 1.13 is wide spread
#			'--squash',
			'--tag', image_tag,
			directory
		]) or raise 'Failed building docker image'


		return image_tag
	end



	# Convenience method for building a DockerContext using a temporary
	# directory
	#
	# @param context {@link BaseDockerContext} to be build
	# @return Docker image identificaton
	def self.build_context(context)
		raise '`context\' must be of type BaseDockerContext' unless context.kind_of?(BaseDockerContext)

		Dir.mktmpdir do |dir|
			directory = Pathname.new dir
			context.write_to directory

			return DockerCli.build directory
		end
	end



	# Replaces current process with executed docker context
	#
	# @param id Id-like interface for access user and group identification
	# @param image Docker image identification
	# @param base_directory Directory to be provided as base volume in
	#     docker context
	# @param command Array of commands to be passed as arguments to docker
	#     entry point
	def self.run(id, image, base_directory, command)
		exec(DockerCli.run_cmd id, image, base_directory, command)
	end

	# Returns the command, {@link DockerCli.run} should exec.
	#
	# @VisibleForTesting
	def self.run_cmd(id, image, base_directory, command)
		uid = id.user_id
		gid = id.group_id

		base_directory = Pathname.new(base_directory).expand_path

		return Shellwords.join([
			'docker',
			'run',
			'-it',
			'--rm',
			'--user', "#{uid}:#{gid}",
			'--volume', "#{base_directory}:#{base_directory}",
			"#{image}"
		] + command)
	end
end

