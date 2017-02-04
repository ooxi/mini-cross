require 'pathname'

require_relative 'configuration-type'



# A {@link ConfigurationType} with directory reference.
class Configuration

	def initialize(directory, type)
		raise "`directory' must be a pathname" unless directory.kind_of?(Pathname)
		raise "`type' must be a ConfigurationType" unless type.kind_of?(ConfigurationType)

		@directory = directory
		@type = type
	end



	def yaml_file
		return @type.yaml_file @directory
	end


	def context_directory
		return @type.context_directory @directory
	end


	def base_directory
		return @type.base_directory @directory
	end

end

