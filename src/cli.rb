


# Parses the desired invocation from ARGV
#
#     [<machine> <command>*]
class Cli

	def initialize(argv)
		@argv = argv
	end



	# Machine can be optional, but if at least one argument is supplied, the
	# first argument must be the machine's name
	#
	# @return Machine name or nil if default machine has to be assumed
	def machine
		if @argv.size < 1
			return nil
		end

		if @argv[0] == '_'
			return nil
		end

		return @argv[0]
	end


	# @return Array of command with arguments to be passed to `docker run`
	def command
		return [] if @argv.empty?
		return @argv[1..@argv.size]
	end
end

