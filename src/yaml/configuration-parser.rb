require 'yaml'

require_relative '../configuration'
require_relative 'base-instruction'
require_relative 'collection-instruction'
require_relative 'copy-instruction'
require_relative 'install-instruction'
require_relative 'nop-instruction'
require_relative 'run-instruction'



# Translates a mini-cross YAML configuration file into the setup of a docker
# context
class YamlConfigurationParser


	# @param configuration {@link Configuration} to parse
	# @return {@link Instruction} to be applied to a docker context
	def self.parse(configuration)
		raise '`configuration\' must be of type `Configuration\'' unless configuration.kind_of?(Configuration)
		instructions = YamlCollectionInstruction.new


		# If context directory is available, contents should be copied
		# into container
		unless configuration.context_directory.nil?
			copy = YamlCopyInstruction.new configuration.context_directory
			instructions.append copy
		end


		# Parse YAML configuration, consting for hashes and shell
		# scripts
		File.open(configuration.yaml_file, 'r:UTF-8') do |config|
			YAML.load_stream(config.read) do |node|
				instruction = parse_node node
				instructions.append instruction
			end
		end

		return instructions
	end





	# Currently two kind of YAML nodes are supported: hash and string nodes.
	def self.parse_node(node)
		if node.kind_of? Hash
			return parse_hash node
		elsif node.kind_of? String
			return parse_string node
		elsif node.nil?
			return YamlNopInstruction.new
		else
			raise "Unsupported YAML node \'#{node}' of type \'#{node.class}'"
		end
	end



	# String nodes contain shell scripts to be executed by the docker
	# container during build
	def self.parse_string(string)
		return YamlRunInstruction.new string
	end



	# @return {@link YamlCollectionInstruction} with instructions for every
	#     key
	def self.parse_hash(hash)
		instruction = YamlCollectionInstruction.new

		hash.each_pair do |key, value|
			if 'base' == key
				instruction.append parse_base(value)
			elsif 'install' == key
				instruction.append parse_install(value)
			else
				raise "Unsupported key \`#{key}' in YAML hash node \`#{hash}'"
			end
		end

		return instruction
	end



	# @return {@link YamlBaseInstruction}
	def self.parse_base(specification)
		return YamlBaseInstruction.new specification
	end



	# @return {@link YamlInstallInstruction}
	def self.parse_install(packages)
		return YamlInstallInstruction.new packages
	end





	private_class_method :parse_node
	private_class_method :parse_string
	private_class_method :parse_hash
	private_class_method :parse_base
	private_class_method :parse_install

end

