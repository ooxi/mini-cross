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

require_relative '../src/id'



class MockId < Id

	def initialize(user_id, user_name, group_id, group_name)
		@user_id = user_id
		@user_name = user_name
		@group_id = group_id
		@group_name = group_name
	end


	def user_id
		return @user_id
	end

	def user_name
		return @user_name
	end


	def group_id
		return @group_id
	end

	def group_name
		return @group_name
	end

end

