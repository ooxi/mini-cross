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

require 'json'
require 'shellwords'



# Provides an abstraction over string operations for composing a Dockerfile.
# Should be replaced by a DSL library
#
# @see https://github.com/nahiluhmot/dockerfile
# @see https://github.com/raviqqe/dockerfile-dsl.rb
class Dockerfile

	def initialize
		@statements = []
	end



	def cmd_exec(exec)
		@statements.push (DockerfileCmdStatement.new exec)
	end

	def cmd_sh(script)
		cmd_exec ['/bin/bash', '-c', script]
	end

	def copy(source, destination)
		@statements.push (DockerfileCopyStatement.new source, destination)
	end

	def env(key, value)
		environment = {key => value}
		@statements.push (DockerfileEnvStatement.new environment)
	end

	def from(image)
		@statements.push (DockerfileFromStatement.new image)
	end

	def run_exec(exec)
		@statements.push (DockerfileRunStatement.new exec)
	end

	def run_sh(script)
		run_exec ['/bin/bash', '-c', script]
	end

	def user(user)
		@statements.push (DockerfileUserStatement.new user)
	end

	def volume(volume)
		volumes [volume]
	end

	def volumes(volumes)
		@statements.push (DockerfileVolumeStatement.new volumes)
	end

	def workdir(workdir)
		@statements.push (DockerfileWorkdirStatement.new workdir)
	end



	def to_s
		return @statements
			.collect{|statement| statement.to_s}
			.join("\n")
	end
end





# Base class for all dockerfile statements
class DockerfileStatement

	def to_s
		raise "Missing implementation"
	end
end



# @see https://docs.docker.com/engine/reference/builder/#/cmd
class DockerfileCmdStatement < DockerfileStatement

	def initialize(exec)
		if not exec.kind_of? Array
			raise "Expected \`exec' to be an Array but is \`#{exec}'"
		end
		@exec = exec
	end

	def exec
		return @exec
	end

	def to_s
		return 'CMD ' + JSON.generate(exec)
	end
end



# @see https://docs.docker.com/engine/reference/builder/#/copy
class DockerfileCopyStatement < DockerfileStatement

	def initialize(source, destination)
		if not source.kind_of? String
			raise "Expected \`source' to be a String but is \`#{source}'"
		end
		if not destination.kind_of? String
			raise "Expected \`destination' to be a String but is \`#{destination}'"
		end
		@source = source
		@destination = destination
	end

	def source
		return @source
	end

	def destination
		return @destination
	end

	def to_s
		return 'COPY ' + JSON.generate([source, destination])
	end
end



# @see https://docs.docker.com/engine/reference/builder/#/env
class DockerfileEnvStatement < DockerfileStatement

	def initialize(environment)
		if not environment.kind_of? Hash
			raise "Expected \`environment' to be a Hash but is \`#{environment}'"
		end
		@environment = environment
	end

	def environment
		return @environment
	end

	def to_s
		return '' if environment.empty?
		env = 'ENV'

		environment.each{|key, value|
			env += ' ' + Shellwords.escape(key) + '=' + Shellwords.escape(value)
		}

		return env
	end
end



# @see https://docs.docker.com/engine/reference/builder/#/from
class DockerfileFromStatement < DockerfileStatement

	def initialize(image)
		if not image.kind_of? String
			raise "Expected \`image' to be a String but is \`#{image}'"
		end
		@image = image
	end

	def image
		return @image
	end

	def to_s
		return 'FROM ' + Shellwords.escape(image)
	end
end



# @see https://docs.docker.com/engine/reference/builder/#/run
class DockerfileRunStatement < DockerfileStatement

	def initialize(exec)
		if not exec.kind_of? Array
			raise "Expected \`exec' to be an Array but is \`#{exec}'"
		end
		@exec = exec
	end

	def exec
		return @exec
	end

	def to_s
		return 'RUN ' + JSON.generate(exec)
	end
end



# @see https://docs.docker.com/engine/reference/builder/#/user
class DockerfileUserStatement < DockerfileStatement

	def initialize(user)
		if not user.kind_of? String
			raise "Expected \`user' to be a String but is \`#{user}'"
		end
		@user = user
	end

	def user
		return @user
	end

	def to_s
		return 'USER ' + Shellwords.escape(user)
	end
end



# @see https://docs.docker.com/engine/reference/builder/#/volume
class DockerfileVolumeStatement < DockerfileStatement

	def initialize(volumes)
		if not volumes.kind_of? Array
			raise "Expected \`volumes' to be an Array but is \`#{volumes}'"
		end
		@volumes = volumes
	end

	def volumes
		return @volumes
	end

	def to_s
		return 'VOLUME ' + JSON.generate(volumes)
	end
end



# @see https://docs.docker.com/engine/reference/builder/#/workdir
class DockerfileWorkdirStatement < DockerfileStatement

	def initialize(workdir)
		if not workdir.kind_of? String
			raise "Expected \`workdir' to be a String but is \`#{workdir}'"
		end
		@workdir = workdir
	end

	def workdir
		return @workdir
	end

	def to_s
		return Shellwords.join ['WORKDIR', workdir]
	end
end

