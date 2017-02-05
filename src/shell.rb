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

require 'open3'



class Shell


	# @see http://blog.honeybadger.io/capturing-stdout-stderr-from-shell-commands-via-ruby/
	def self.run(command)
		Open3.popen2e(command) do |stdin, stdout_and_stderr, wait_thread|
			while line=stdout_and_stderr.gets do
				puts line
			end

			return wait_thread.value.success?
		end
	end

end

