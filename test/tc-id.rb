require 'test/unit'

require_relative '../src/id'




 
class TestId < Test::Unit::TestCase


	# @see https://stackoverflow.com/a/5661695/2534648
	#
	# @author Jakob S
	# @author Josh Pinter
	def is_number? string
		true if Float(string) rescue false
	end



	def test_UserId
		uid = RealId.new.user_id
		assert(is_number?(uid), "User id must be numeric but #{uid} is not")
	end


	def test_UserName
		user = RealId.new.user_name
		assert_not_nil(user, 'User name must not be null')
	end


	def test_GroupId
		gid = RealId.new.group_id
		assert(is_number?(gid), "Group id must be numeric but #{gid} is not")
	end


	def test_GroupName
		group = RealId.new.group_name
		assert_not_nil(group, 'Group name must not be null')
	end

end

