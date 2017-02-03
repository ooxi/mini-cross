

# Abstraction of [id](https://linux.die.net/man/1/id)
class Id


	def self.user_id
		`id --user`.chomp
	end

	def self.user_name
		`id --user --name`.chomp
	end


	def self.group_id
		`id --group`.chomp
	end

	def self.group_name
		`id --group --name`.chomp
	end

end

