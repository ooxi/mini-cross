

# Abstraction of [id](https://linux.die.net/man/1/id)
class Id

	def self.real
		return RealId.new
	end


	def user_id
		raise 'Must be overwritten by implementation'
	end

	def user_name
		raise 'Must be overwritten by implementation'
	end


	def group_id
		raise 'Must be overwritten by implementation'
	end

	def group_name
		raise 'Must be overwritten by implementation'
	end

end



class RealId < Id


	def user_id
		`id --user`.chomp
	end

	def user_name
		`id --user --name`.chomp
	end


	def group_id
		`id --group`.chomp
	end

	def group_name
		`id --group --name`.chomp
	end
end

