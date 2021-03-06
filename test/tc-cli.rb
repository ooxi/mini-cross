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

require_relative '../src/cli'





class TestDockerContext < Test::Unit::TestCase


	def test_UnnamedMachineNoArgv
		cli = Cli.new []

		assert_nil(cli.machine, 'Should assume default machine')
		assert_equal([], cli.command, 'No command should be provided')
		assert(cli.tty, 'Should assume tty')
	end


	def test_NamedMachineNoArgv
		cli = Cli.new ['machine']

		assert_equal('machine', cli.machine, 'Wrong machine')
		assert_equal([], cli.command, 'No command should be provided')
		assert(cli.tty, 'Should assume tty')
	end


	def test_UnnamedMachineWithArgv
		cli = Cli.new ['_', 'ab', '--c']

		assert_nil(cli.machine, 'Should assume default machine')
		assert_equal(['ab', '--c'], cli.command, 'Wrong command')
		assert(cli.tty, 'Should assume tty')
	end


	def test_NamedMachineWithArgv
		cli = Cli.new ['machine', 'ab', '--c']

		assert_equal('machine', cli.machine, 'Wrong machine')
		assert_equal(['ab', '--c'], cli.command, 'Wrong command')
		assert(cli.tty, 'Should assume tty')
	end





	def test_NoTtyUnnamedMachineNoArgv
		cli = Cli.new ['--no-tty']

		assert_nil(cli.machine, 'Should assume default machine')
		assert_equal([], cli.command, 'No command should be provided')
		assert(!cli.tty, 'No tty was explicitly required')
	end


	def test_NoTtyNamedMachineNoArgv
		cli = Cli.new ['--no-tty', 'machine']

		assert_equal('machine', cli.machine, 'Wrong machine')
		assert_equal([], cli.command, 'No command should be provided')
		assert(!cli.tty, 'No tty was explicitly required')
	end


	def test_NoTtyUnnamedMachineWithArgv
		cli = Cli.new ['--no-tty', '_', 'ab', '--c']

		assert_nil(cli.machine, 'Should assume default machine')
		assert_equal(['ab', '--c'], cli.command, 'Wrong command')
		assert(!cli.tty, 'No tty was explicitly required')
	end


	def test_NoTtyNamedMachineWithArgv
		cli = Cli.new ['--no-tty', 'machine', 'ab', '--c']

		assert_equal('machine', cli.machine, 'Wrong machine')
		assert_equal(['ab', '--c'], cli.command, 'Wrong command')
		assert(!cli.tty, 'No tty was explicitly required')
	end
end

