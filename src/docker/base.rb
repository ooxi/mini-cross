# Copyright (c) 2017 github/ooxi
#     https://github.com/ooxi/mini-cross
#
# This software is provided 'as-is', without any express or implied warranty. In
# no event will the authors be held liable for any damages arising from the use
# of this software.
#
# Permission is granted to anyone to use this software for any purpose,
# including commercial applications, and to alter it and redistribute it freely,
# subject to the following restrictions:
#
#  1. The origin of this software must not be misrepresented; you must not claim
#     that you wrote the original software. If you use this software in a product,
#     an acknowledgment in the product documentation would be appreciated but is
#     not required.
#
#  2. Altered source versions must be plainly marked as such, and must not be
#     misrepresented as being the original software.
#
#  3. This notice may not be removed or altered from any source distribution.

require 'fileutils'
require 'pathname'

require_relative 'dockerfile'



class BaseDockerContext


	public
	def initialize(dockerfile)
		if not dockerfile.kind_of? Dockerfile
			raise "Expected \`dockerfile' to be of type \`Dockerfile' but is \`#{dockerfile.class}'"
		end

		@dockerfile = dockerfile
		@sources = Array.new
	end





	# @warning Still required by `mini-cross.rb'
#	protected
	def dockerfile
		return @dockerfile
	end



	public
	def copy(source)
		raise '`source\' must be a pathname' unless source.kind_of?(Pathname)
		rause "`source' must be a directory but #{source} is not" unless source.directory?

		# Sources will be copied into context directory named like array
		# index
		@sources.push(source)
		index = @sources.size - 1

		@dockerfile.copy index.to_s, '/'
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
			f.write @dockerfile.to_s
		end

		@sources.each_with_index do |source, index|
			destination = directory + index.to_s
			destination.mkpath

			# @see https://stackoverflow.com/a/26048337/2534648
			FileUtils.cp_r(source.to_s + '/.', destination)
		end
	end
end

