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



# Parses the desired invocation from ARGV
#
#     [<options>* <machine> <command>*]
class Cli

	def initialize(argv)
		@options = self.class.parse_options_from_arguments argv
		@argv = self.class.parse_machine_and_command_from_arguments argv
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


	# @return true iff. interactive/tty mode should be used by `docker run`
	def tty
		return !(@options.include? '--no-tty')
	end





	# @return The options to mini-cross from `argv`, which are all elements
	#     starting with `--` until the first element not starting with that
	#     prefix
	#
	# @warning Should be private
	def self.parse_options_from_arguments(argv)
		options = []

		for arg in argv
			if arg.start_with? '--'
				options.push arg
			else
				return options
			end
		end

		return options
	end


	# @return Machine name followed by command (everything after the
	#     options)
	#
	# @warning Should be private
	def self.parse_machine_and_command_from_arguments(argv)
		options = self.parse_options_from_arguments argv
		return argv[options.size..argv.size]
	end
end

