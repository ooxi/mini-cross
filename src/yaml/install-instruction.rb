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



# Instruct to install a set of packages
class YamlInstallInstruction < YamlInstruction


	def initialize(packages)
		@packages = packages

		if not @packages.kind_of? Array
			raise "Expected array of package names, got \`#{@packages}'"
		end

		@packages.each do |package|
			if not package.kind_of? String
				raise "Expected package name, got \`#{package}' in \`#{@packages}'"
			end
		end
	end



	def apply_to(docker_context)
		raise '`docker-context\' should be of type BaseDockerContext' unless docker_context.kind_of?(BaseDockerContext)
		docker_context.install @packages
	end

end

