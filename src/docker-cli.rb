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

require 'digest'
require 'pathname'
require 'shellwords'
require 'tmpdir'

require_relative 'docker/base'
require_relative 'docker/docker-run-arguments'
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
	# @param image Docker image identification
	# @param arguments Arguments to passed to docker run
	# @param tty Should `docker run` require a tty
	# @param command Array of commands to be passed as arguments to docker
	#     entry point
	def self.run(image, arguments, tty, command)
		exec(DockerCli.run_cmd image, arguments, tty, command)
	end

	# Returns the command, {@link DockerCli.run} should exec.
	#
	# @VisibleForTesting
	def self.run_cmd(image, arguments, tty, command)
		if not arguments.kind_of? DockerRunArguments
			raise "\`arguments' must be of type DockerRunArguments"
		end

		if not [true, false].include? tty
			raise "\`tty' must be of type bool"
		end

		tty = tty ? ['--interactive', '--tty'] : []

		escaped_arguments = [
			'docker',
			'run',
			'--rm',
		] + tty + arguments.to_args

		unescaped_arguments = [image] + command

		return escaped_arguments.join(' ') + ' ' + Shellwords.join(unescaped_arguments)
	end
end

