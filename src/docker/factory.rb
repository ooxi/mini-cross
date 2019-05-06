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

require_relative '../id'
require_relative 'arch'
require_relative 'debian'
require_relative 'fedora'
require_relative 'ubuntu'



# Provides a factory for creating {@link BaseDockerContext} instances from
# specification
#
#  a) `archlinux/…' → {@link ArchDockerContext}
#  b) `debian:…' → {@link DebianDockerContext}
#  c) `fedora:…' → {@link FedoraDockerContext}
#  d) `ubuntu:…' → {@link UbuntuDockerContext}
#
# @see YamlBaseInstruction
class DockerContextFactory


	# @param id {@link Id}-like
	def initialize(id)
		@id = id

		raise '`id\' should have been of type Id' unless @id.kind_of? Id
	end



	def from_specification(specification)

		if specification.start_with? 'archlinux/'
			return ArchDockerContext.new @id, specification

		elsif specification.start_with? 'debian:'
			return DebianDockerContext.new @id, specification

		elsif specification.start_with? 'fedora:'
			return FedoraDockerContext.new @id, specification

		elsif specification.start_with? 'ubuntu:'
			return UbuntuDockerContext.new @id, specification

		else
			raise "Unsupported docker context specification \`#{specification}'"
		end
	end

end

