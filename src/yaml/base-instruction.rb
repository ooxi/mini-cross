require 'yaml'

require_relative 'instruction'



# Special instruction for recording the desired docker base
#
# @see DockerContextFactory
class YamlBaseInstruction < YamlInstruction

	def initialize(base)
		@base = base
	end



	def apply_to(docker_context)
		# NOP
	end


	# @return Recorded base (e.g. `ubuntu:16.04')
	def base
		return @base
	end

end

