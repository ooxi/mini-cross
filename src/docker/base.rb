require 'fileutils'
require 'pathname'



class BaseDockerContext


	public
	def initialize(dockerfile)
		@dockerfile = dockerfile
		@sources = Array.new
	end





	#protected
	def dockerfile(content)
		@dockerfile += "\n\n\n" + content
	end



	public
	def copy(source)
		raise '`source\' must be a pathname' unless source.kind_of?(Pathname)
		rause "`source' must be a directory but #{source} is not" unless source.directory?

		# Sources will be copied into context directory named like array
		# index
		@sources.push(source)
		dockerfile "COPY #{@sources.size - 1} /"
	end



	def install(packages)
		raise 'Must be overwritten by implementation'
	end



	# Writes the Docker context's current state into the supplied directory
	#
	# @param directory Pathname to be used for output
	public
	def write_to(directory)
		raise '`directory\' must be a pathname' unless directory.kind_of?(Pathname)

		File.open(directory + 'Dockerfile', 'w:UTF-8') do |f|
			f.write @dockerfile
		end

		@sources.each_with_index do |source, index|
			destination = directory + index.to_s
			destination.mkpath

			# @see https://stackoverflow.com/a/26048337/2534648
			FileUtils.cp_r(source.to_s + '/.', destination)
		end
	end
end

