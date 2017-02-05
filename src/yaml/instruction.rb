require_relative '../docker/base'



# Abstract base class for instructions from mini-cross YAML configuration files
class YamlInstruction


	# Apply instruction to provided docker context
	def apply_to(docker_context)
		raise '`docker-context\' should be of type BaseDockerContext' unless docker_context.kind_of?(BaseDockerContext)
		raise 'Must be overwritten in implementation'
	end


	# @return {@link TODO} which this instruction is referring to, might
	#     be nil if no explicit base is defined
	def base
		return nil
	end

end

