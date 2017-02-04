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

