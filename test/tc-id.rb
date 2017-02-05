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

