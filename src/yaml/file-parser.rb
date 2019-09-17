# Copyright (c) 2019 github/ooxi
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

require_relative 'base-instruction'
require_relative 'file-collection-instruction'
require_relative 'front-matter-collection-instruction'
require_relative 'install-instruction'
require_relative 'mixin-collection-instruction'
require_relative 'nop-instruction'
require_relative 'publish-instruction'
require_relative 'run-instruction'



# Parses a YAML configuration file without directory context into a number of
# instructions.
#
# @see YamlConfigurationParser
class YamlFileParser


	def self.parse(root_configuration)
		return new.parse_configuration root_configuration
	end



	# Must only be called by #parse
	def initialize
		@configurations = Array.new
	end

	private_class_method :new





	# @return YamlCollectionInstruction or YamlNopInstruction
	def parse_configuration(configuration)
		raise '`configuration\' must be a pathname' unless configuration.kind_of?(Pathname)


		# If configuration was already parsed before, we can skip
		# reparsing this
		if @configurations.include? configuration
			return YamlNopInstruction.new
		end

		@configurations.push configuration


		# Parse configuration, consting of a YAML front matter and a
		# shell script
		instructions = YamlFileCollectionInstruction.new

		File.open(configuration, 'r:UTF-8') do |config|
			parsed = FrontMatterParser.parse(config.read)

			instructions.append (parse_node(parsed.front_matter, configuration))
			instructions.append (parse_node(parsed.content, configuration))
		end

		return instructions
	end



	# Currently two kind of YAML nodes are supported: hash and string nodes.
	def parse_node(node, relative_to)
		raise '`relative_to\' must be a pathname' unless relative_to.kind_of?(Pathname)

		if node.kind_of? Hash
			return parse_hash(node, relative_to)
		elsif node.kind_of? String
			return parse_string(node)
		elsif node.nil?
			return YamlNopInstruction.new
		else
			raise "Unsupported YAML node \'#{node}' of type \'#{node.class}'"
		end
	end



	# String nodes contain shell scripts to be executed by the docker
	# container during build
	def parse_string(string)
		return YamlRunInstruction.new string
	end



	# @return {@link YamlCollectionInstruction} with instructions for every
	#     key
	def parse_hash(hash, relative_to)
		raise '`relative_to\' must be a pathname' unless relative_to.kind_of?(Pathname)

		instruction = YamlFrontMatterCollectionInstruction.new

		hash.each_pair do |key, value|
			if 'base' == key
				instruction.append parse_base(value)
			elsif 'install' == key
				instruction.append parse_install(value)
			elsif 'mixin' == key
				instruction.append parse_mixins(value, relative_to)
			elsif 'publish' == key
				instruction.append parse_publish(value)
			else
				raise "Unsupported key \`#{key}' in YAML hash node \`#{hash}'"
			end
		end

		return instruction
	end



	# @return {@link YamlBaseInstruction}
	def parse_base(specification)
		return YamlBaseInstruction.new specification
	end



	# @return {@link YamlInstallInstruction}
	def parse_install(packages)
		return YamlInstallInstruction.new packages
	end



	# @return {@link YamlCollectionInstruction}
	def parse_mixins(mixins, relative_to)
		raise '`relative_to\' must be a pathname' unless relative_to.kind_of?(Pathname)

		instructions = YamlMixinCollectionInstruction.new

		mixins.each do |mixin|
			path = relative_to.dirname + (mixin + '.yaml')

			if !path.exist?
				raise "Cannot find mixin `#{mixin}\' at `#{path}\'"
			end

			instructions.append parse_configuration(path)
		end

		return instructions
	end



	# @return {@link YamlPublishInstruction}
	def parse_publish(packages)
		return YamlPublishInstruction.new packages
	end

end

