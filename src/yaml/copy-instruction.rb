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

require_relative '../docker/base'
require_relative 'instruction'



# Instruct to copy a directory into the container
class YamlCopyInstruction < YamlInstruction


	def initialize(directory)
		@directory = Pathname.new directory
		raise "\`directory' must be a directory but \`#{directory}' is not" unless @directory.directory?
	end


	def apply_to(docker_context)
		raise '`docker-context\' should be of type BaseDockerContext' unless docker_context.kind_of?(BaseDockerContext)
		docker_context.copy @directory
	end
end

