require_relative '../docker/base'
require_relative 'instruction'



# Will execute a set of instructions in given order
class YamlCollectionInstruction < YamlInstruction

	def initialize
		@instructions = Array.new
	end



	def append(instruction)
		raise '`instruction\' must be of type Instruction' unless instruction.kind_of?(YamlInstruction)
		@instructions.push(instruction)
	end

	def prepend(instruction)
		raise '`instruction\' must be of type Instruction' unless instruction.kind_of?(YamlInstruction)
		@instructions.unshift(instruction)
	end





	# Applies each instruction to provided docker context
	def apply_to(docker_context)
		raise '`docker-context\' should be of type BaseDockerContext' unless docker_context.kind_of?(BaseDockerContext)

		@instructions.each do |instruction|
			instruction.apply_to docker_context
		end
	end


	# @return Last recorded base
	def base
		base = nil

		@instructions.each do |instruction|
			base = instruction.base unless instruction.base.nil?
		end

		return base
	end

end

