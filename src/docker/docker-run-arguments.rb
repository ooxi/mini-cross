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

require_relative '../id'



# Abstraction of `docker run'-invocation
#
# @see https://docs.docker.com/engine/reference/run/
class DockerRunArguments

	def initialize
		@publications = []
		@user = DockerUserArgument.new nil
		@volumes = []
		@workdir = DockerWorkdirArgument.new nil
	end


	def publish(ip, host_port, container_port)
		publication = DockerPublishArgument.new ip, host_port, container_port
		@publications.push publication
	end

	def user(id)
		@user = DockerUserArgument.new id
	end

	def add_volume(host_source, container_destination, options)
		volume = DockerVolumeArgument.new pn(host_source), pn(container_destination), options
		@volumes.push volume
	end

	def workdir(workdir)
		@workdir = DockerWorkdirArgument.new pn(workdir)
	end



	# @return Array of shell escaped arguments
	def to_args
		args = []


		args.concat @user.to_args

		@volumes.each do |volume|
			args.concat volume.to_args
		end

		args.concat @workdir.to_args

		@publications.each do |publication|
			args.concat publication.to_args
		end


		return args
	end


	# Utility method to accept both String and Pathname
	def pn(string_or_pathname)
		if string_or_pathname.kind_of? String
			return Pathname.new string_or_pathname
		elsif string_or_pathname.kind_of? Pathname
			return string_or_pathname
		else
			raise "Expected String or Pathname but argument \`#{string_or_pathname}' is \`#{string_or_pathname.class}'"
		end
	end

end





# Base class for all argument wrappers
class DockerArgument

	# @return Array of shell escaped arguments
	def to_args
		raise 'Missing implementation'
	end
end



# @see https://docs.docker.com/engine/reference/run/#expose-incoming-ports
class DockerPublishArgument < DockerArgument

	def initialize(ip, host_port, container_port)
		if (not ip.nil?) and (not ip.kind_of? String)
			raise "\`ip' must be of type \`String' or nil but \`#{ip}' is of type \`#{ip.class}'"
		end
		if (not host_port.nil?) and (not host_port.is_a? Integer)
			raise "\`host_port' must be of type \`Integer' or nil but \`#{host_port}' is of type \`#{host_port.class}'"
		end
		if (not container_port.nil?) and (not container_port.kind_of? Integer)
			raise "\`container_port' must be of type \`Integer' or nil but \`#{container_port}' is of type \`#{container_port.class}'"
		end

		@ip = ip
		@host_port = host_port
		@container_port = container_port
	end


	def to_args
		# ip:hostPort:containerPort
		if (not @ip.nil?) and (not @host_port.nil?) and (not @container_port.nil?)
			specification = [@ip, @host_port, @container_port]
			return ['-p', specification.collect{|u| Shellwords.escape u}.join(':')]
		end

		# ip::containerPort
		if (not @ip.nil?) and @host_port.nil? and (not @container_port.nil?)
			return ['-p', (Shellwords.escape @ip) + '::' + (Shellwords.escape @container_port)]
		end

		# hostPort:containerPort
		if @ip.nil? and (not @host_port.nil?) and (not @container_port.nil?)
			return ['-p', (Shellwords.escape @host_port) + ':' + (Shellwords.escape @container_port)]
		end

		# containerPort
		if @ip.nil? and @host_port.nil? and (not @container_port.nil?)
			return ['-p', (Shellwords.escape @container_port)]
		end

		raise 'Illegal state'
	end
end



# @see https://docs.docker.com/engine/reference/run/#/user
class DockerUserArgument < DockerArgument

	def initialize(id)
		if (not id.nil?) and (not id.kind_of? Id)
			raise "\`id' must be of type \`Id' or nil but \`#{id}' is of type \`#{id.class}'"
		end
		@id = id
	end


	def to_args
		if @id.nil?
			return []
		end

		user = [@id.user_id, @id.group_id]
		return ['-u', user.collect{|u| Shellwords.escape u}.join(':')]
	end
end



# @see https://docs.docker.com/engine/reference/run/#/volume-shared-filesystems
class DockerVolumeArgument < DockerArgument

	def initialize(host_source, container_destination, options)
		if not host_source.kind_of? Pathname
			raise "\`host_source' must be of type \`Pathname' but \`#{host_source}' is of type \`#{host_source.class}'"
		end
		if not container_destination.kind_of? Pathname
			raise "\`container_destination' must be of type \`Pathname' but \`#{container_destination}' is of type \`#{container_destination.class}'"
		end
		if not options.kind_of? Array
			raise "\`options' must be of type \`Array' but \`#{options}' is of type \`#{options.class}'"
		end

		@host_source = host_source
		@container_destination = container_destination
		@options = options
	end


	def to_args

		# @warning I'm not using `expand_path' here, because
		#     `container_destination' might resolve differently on the
		#     host. Therefore the user has to take care to provide
		#     absolute paths, otherwise the docker invocation will fail
		volume = [
			@host_source.to_s,
			@container_destination.to_s
		]
		volume.push (@options.join ',') unless @options.empty?


		return ['-v', volume.collect{|v| Shellwords.escape v}.join(':')]
	end
end



# @see https://docs.docker.com/engine/reference/run/#/workdir
class DockerWorkdirArgument < DockerArgument

	def initialize(workdir)
		if (not workdir.nil?) and (not workdir.kind_of? Pathname)
			raise "\`workdir' must be of type \`Pathname' or nil but \`#{workdir}' is of type \`#{workdir.class}'"
		end

		@workdir = workdir
	end


	def to_args
		if @workdir.nil?
			return []
		end

		return ['-w', Shellwords.escape(@workdir.to_s)]
	end
end

