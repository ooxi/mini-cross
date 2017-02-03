require 'test/unit'

require_relative '../src/shell'





class TestId < Test::Unit::TestCase


	def test_True
		rc = Shell.run 'true'
		assert(rc, 'Return code should have been true')
	end

	def test_False
		rc = Shell.run 'false'
		assert(!rc, 'Return code should have been false')
	end
end

