require_relative '../id'
require_relative 'fedora'
require_relative 'ubuntu'



# Provides a factory for creating {@link BaseDockerContext} instances from
# specification
#
#  a) `fedora:…' → {@link FedoraDockerContext}
#  b) `ubuntu:…' → {@link UbuntuDockerContext}
#
# @see YamlBaseInstruction
class DockerContextFactory


	# @param id {@link Id}-like
	def initialize(id)
		@id = id

		raise '`id\' should have been of type Id' unless @id.kind_of? Id
	end



	def from_specification(specification)

		if specification.start_with? 'fedora:'
			return FedoraDockerContext.new @id, specification

		elsif specification.start_with? 'ubuntu:'
			return UbuntuDockerContext.new @id, specification

		else
			raise "Unsupported docker context specification \`#{specification}'"
		end
	end

end

