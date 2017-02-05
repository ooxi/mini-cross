require 'base64'
require 'shellwords'

require_relative '../docker/base'
require_relative 'instruction'



# Instruct to execute a shell script
class YamlRunInstruction < YamlInstruction


	def initialize(script)
		@script = script
	end


	def apply_to(docker_context)
		raise '`docker-context\' should be of type BaseDockerContext' unless docker_context.kind_of?(BaseDockerContext)

		echo = Shellwords.join ['echo', Base64.strict_encode64(@script)]

		docker_context.dockerfile <<-DOCKERFILE
			RUN	#{echo} | base64 -d - | bash
		DOCKERFILE
	end
end

