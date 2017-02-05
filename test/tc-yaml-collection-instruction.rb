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

