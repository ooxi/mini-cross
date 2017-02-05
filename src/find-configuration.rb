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

require 'pathname'

require_relative 'configuration'
require_relative 'configuration-type'



class FindConfiguration


	# Will search for the relevant mini-cross configuration in the following
	# locations and return the first found machine
	#
	#  a. $directory/.mc/mc.yaml
	#  b. $directory/mc.yaml
	#  c. Move $directory up if not already in filesystem root and continue
	#     with a)
	#
	# @param directory Reference directory
	#
	# @return path to configuration or nil if not found
	def self.without_name(directory)
		a = ConfigurationType.new('.mc/mc.yaml',	'.mc/',	'.')
		b = ConfigurationType.new('mc.yaml',		nil,	'.')

		return by_type(Pathname.new(directory), [a, b])
	end


	# Will search for the relevant mini-cross configuration in the following
	# locations and return the first found machine
	#
	#  a. $directory/.mc/$name/$name.yaml
	#  b. $directory/.mc/$name.yaml
	#  c. $directory/mc.$name.yaml
	#  d. Move $directory up if not already in filesystem root and continue
	#     with a)
	#
	# @param directory
	# @param name Machine name
	# @return path to configuration or nil if not found
	def self.named(directory, name)
		a = ConfigurationType.new(".mc/#{name}/#{name}.yaml",	".mc/#{name}/",	'.')
		b = ConfigurationType.new(".mc/#{name}.yaml",		nil,		'.')
		c = ConfigurationType.new("mc.#{name}.yaml",		nil,		'.')

		return by_type(Pathname.new(directory), [a, b, c])
	end



	# Will test for multiple files relative to a path and return the first
	# match. Will ascend to parent directories and repeat test until root
	# is reached. Will return nil if no test succeeded until root was
	# reached.
	#
	# @param directory Path reference
	# @param types Array of {@link ConfigurationType} to test
	#
	# @return First successful {@link ConfigurationType} as
	#     {@link Configuration} or nil
	def self.by_type(directory, types)
		directory = directory.expand_path

		# Ascend to parent directory until filesystem root
		directory.ascend do |dir|

			# Test specific locations
			types.each do |type|
				config = type.yaml_file(dir)

				if config.file?
					return Configuration.new(dir, type)
				end
			end
		end

		return nil
	end

	private_class_method :by_type

end

