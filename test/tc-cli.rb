require 'test/unit'

require_relative '../src/cli'





class TestDockerContext < Test::Unit::TestCase


	def test_UnnamedMachineNoArgv
		cli = Cli.new []

		assert_nil(cli.machine, 'Should assume default machine')
		assert_equal([], cli.command, 'No command should be provided')
	end


	def test_NamedMachineNoArgv
		cli = Cli.new ['machine']

		assert_equal('machine', cli.machine, 'Wrong machine')
		assert_equal([], cli.command, 'No command should be provided')
	end


	def test_UnnamedMachineWithArgv
		cli = Cli.new ['_', 'ab', 'c']

		assert_nil(cli.machine, 'Should assume default machine')
		assert_equal(['ab', 'c'], cli.command, 'Wrong command')
	end


	def test_NamedMachineWithArgv
		cli = Cli.new ['machine', 'ab', 'c']

		assert_equal('machine', cli.machine, 'Wrong machine')
		assert_equal(['ab', 'c'], cli.command, 'Wrong command')
	end
end

