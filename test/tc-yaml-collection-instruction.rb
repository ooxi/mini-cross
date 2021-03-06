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

require_relative '../src/yaml/instruction'
require_relative '../src/yaml/collection-instruction'



class TestYamlCollectionInstruction < Test::Unit::TestCase


	def test_Base
		ci = YamlCollectionInstruction.new
		assert(ci.kind_of?(YamlInstruction), 'YamlCollectionInstruction should be of kind YamlInstruction')

		assert_nil(ci.base, 'Base of YamlCollectionInstruction with no instruction should have been nil')

		ci.append MockBaseInstructionA.new
		assert_equal('base a', ci.base, 'MockBaseInstructionA should have provided `base a\'')

		ci.append MockBaseInstructionB.new
		assert_equal('base b', ci.base, 'MockBaseInstructionB should have overwritten `base a\' to `base b\'')

		ci.append MockBaseInstructionC.new
		assert_equal('base b', ci.base, 'Since MockBaseInstructionC does not define `base\', `ci.base\' should have remained at `base b\'')
	end

end



class MockBaseInstructionA < YamlInstruction

	def base
		return 'base a'
	end
end

class MockBaseInstructionB < YamlInstruction

	def base
		return 'base b'
	end
end

class MockBaseInstructionC < YamlInstruction
end

