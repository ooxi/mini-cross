require 'pathname'



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
		return by_test(directory, [
			'.mc/mc.yaml',
			'mc.yaml'
		])
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
		return by_test(directory, [
			".mc/#{name}/#{name}.yaml",
			".mc/#{name}.yaml",
			"#{name}.yaml"
		])
	end



	# Will test for multiple files relative to a path and return the first
	# match. Will ascend to parent directories and repeat test until root
	# is reached. Will return nil if no test succeeded until root was
	# reached.
	#
	# @param directory Path reference
	# @param tests Array of tests to execute
	#
	# @return First successful test or nil
	def self.by_test(directory, tests)
		directory = File.expand_path(directory)

		# Test specific locations
		tests.each do |test|
			config = "#{directory}/#{test}"

			if File.file? config
				return config
			end
		end

		# File not found, ascend to parent directory if not already root
		parent = File.expand_path(File.join(directory, './..'))

		if parent == directory
			return nil
		end

		return by_test(parent, tests)
	end

	private_class_method :by_test





	# @param config Configuration file path
	# @return Context directory of configuration or nil if non available
	def self.context(config)
		config = Pathname.new File.expand_path(config)

		basename = File.basename(config.basename, '.yaml')
		parent = config.dirname.basename.to_s
		grandparent = config.dirname.dirname.basename.to_s

		# .mc/mc.yaml → .mc/
		if ('.mc' == parent) && ('mc' == basename)
			return config.dirname.to_s
		end

		# .mc/machine/machine.yaml → .mc/machine/
		if ('.mc' == grandparent) && (basename == parent)
			return config.dirname.to_s
		end

		return nil
	end

end

