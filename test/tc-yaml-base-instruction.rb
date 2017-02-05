require 'test/unit'

require_relative '../src/yaml/instruction'
require_relative '../src/yaml/base-instruction'



class TestYamlBaseInstruction < Test::Unit::TestCase


	def test_Base
		i = YamlInstruction.new
		bi = YamlBaseInstruction.new 'ubuntu:16.04'

		assert_nil(i.base, 'base of YamlInstruction should have been nil')
		assert_equal('ubuntu:16.04', bi.base, 'Wrong base of YamlBaseInstruction')
	end
end

