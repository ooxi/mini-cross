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



# A mini-cross configuration consists of three main properties
#
#  1. The initial yaml configuration file
#  2. A context directory for the development environment (files copied into the
#     root file system of the container
#  3. A base directory, mounted inside the development environment
#
# Since there are multiple ways to setup a mini-cross configuration, this class
# determines the relative position of these file system elements
class ConfigurationType

	# @param yaml Relative position of yaml configuration file
	# @param context Relative position of context directory, might be nil
	# @param base Relative position of base directory
	def initialize(yaml, context, base)
		@yaml = yaml
		@context = context
		@base = base
	end





	def yaml_file(directory)
		raise "`directory' must be a pathname" unless directory.kind_of?(Pathname)
		return directory + @yaml
	end


	def context_directory(directory)
		if @context.nil?
			return nil
		end

		raise "`directory' must be a pathname" unless directory.kind_of?(Pathname)
		return directory + @context
	end


	def base_directory(directory)
		raise "`directory' must be a pathname" unless directory.kind_of?(Pathname)
		return directory + @base
	end
end

