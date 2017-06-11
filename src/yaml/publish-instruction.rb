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

require_relative '../docker/base'
require_relative 'instruction'



# Instruct to publish a set of port forwardings
class YamlPublishInstruction < YamlInstruction


	def initialize(publications)

		if not publications.kind_of? Array
			raise "Expected array of publication descriptions, got \`#{publications}'"
		end

		@publications = publications.collect{|publication|
			YamlPublishInstruction.parse_publication publication
		}
	end



	def apply_to(docker_context)
		raise '`docker-context\' should be of type BaseDockerContext' unless docker_context.kind_of?(BaseDockerContext)

		@publications.each{|publication|
			docker_context.run.publish publication.ip, publication.host_port, publication.container_port
		}
	end




	# format: ip:hostPort:containerPort | ip::containerPort | hostPort:containerPort | containerPort
	#
	# @see https://docs.docker.com/engine/reference/run/#expose-incoming-ports
	def self.parse_publication(publication)
		if not publication.kind_of? String
			raise "\`publication' must be of type \`String' but \`#{publication}' is of type \`#{publication.class}'"
		end

		# @warning Does not work with IPv6 host IP! But docker does
		#     neither…
		parts = publication.split(':')

		if (3 == parts.length)
			return YamlPublishInstructionPublication.new parts[0], parts[1], parts[2]
		elsif (2 == parts.length)
			return YamlPublishInstructionPublication.new '', parts[0], parts[1]
		elsif (1 == parts.length)
			return YamlPublishInstructionPublication.new '', '', parts[0]
		else
			raise "\`publication' must have a format like ip:host_port:container_port | ip::container_port | hostPort:container_port | container_port but \`#{publication}' does not"
		end
	end

end





class YamlPublishInstructionPublication

	def initialize(ip, host_port, container_port)
		@ip = if ip.empty?
			nil
		else
			ip
		end

		@host_port = if host_port.empty?
			nil
		else
			Integer(host_port)
		end

		@container_port = Integer(container_port)
	end


	def ip
		return @ip
	end

	def host_port
		return @host_port
	end

	def container_port
		return @container_port
	end
end

