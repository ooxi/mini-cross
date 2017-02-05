require_relative 'instruction'



# Will do nothing (used for empty YAML configuration nodes)
class YamlNopInstruction < YamlInstruction


	def apply_to(docker_context)
		# NOP
	end

end

