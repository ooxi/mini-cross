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

