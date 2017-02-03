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

