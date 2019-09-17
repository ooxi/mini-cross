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

require 'front_matter_parser'

require_relative '../configuration'
require_relative 'configuration-collection-instruction'
require_relative 'copy-instruction'
require_relative 'file-parser'



# Translates a mini-cross YAML configuration into the setup of a docker context.
#
# While {@link YamlFileParser} only looks at the YAML file itself, this class
# also copies the context directory into the docker context.
#
# @see YamlFileParser
class YamlConfigurationParser


	# @param configuration {@link Configuration} to parse
	# @return {@link Instruction} to be applied to a docker context
	def self.parse(configuration)
		raise '`configuration\' must be of type `Configuration\'' unless configuration.kind_of?(Configuration)
		instructions = YamlConfigurationCollectionInstruction.new


		# If context directory is available, contents should be copied
		# into container
		unless configuration.context_directory.nil?
			copy = YamlCopyInstruction.new configuration.context_directory
			instructions.append copy
		end


		# Delegate parsing of YAML file to YamlFileParser
		instructions.append YamlFileParser.parse configuration.yaml_file


		return instructions
	end

end

