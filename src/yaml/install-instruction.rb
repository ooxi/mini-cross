require_relative '../docker/base'
require_relative 'instruction'



# Instruct to install a set of packages
class YamlInstallInstruction < YamlInstruction


	def initialize(packages)
		@packages = packages

		if not @packages.kind_of? Array
			raise "Expected array of package names, got \`#{@packages}'"
		end

		@packages.each do |package|
			if not package.kind_of? String
				raise "Expected package name, got \`#{package}' in \`#{@packages}'"
			end
		end
	end



	def apply_to(docker_context)
		raise '`docker-context\' should be of type BaseDockerContext' unless docker_context.kind_of?(BaseDockerContext)
		docker_context.install @packages
	end

end

