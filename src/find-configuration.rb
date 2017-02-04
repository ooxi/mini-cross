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
		c = ConfigurationType.new("#{name}.yaml",		nil,		'.')

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

