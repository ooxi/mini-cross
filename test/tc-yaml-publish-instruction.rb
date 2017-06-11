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

require_relative '../src/yaml/publish-instruction'



class TestYamlPublishInstruction < Test::Unit::TestCase


	def test_ParseIpHostContainer
		pub = YamlPublishInstruction.parse_publication '127.0.0.1:8080:80'

		assert(pub.kind_of?(YamlPublishInstructionPublication), 'publication should be of kind YamlPublishInstructionPublication')
		assert_equal('127.0.0.1', pub.ip, 'Publication has wrong ip')
		assert_equal(8080, pub.host_port, 'Publication has wrong host port')
		assert_equal(80, pub.container_port, 'Publication has wrong container port')
	end


	def test_ParseIpContainer
		pub = YamlPublishInstruction.parse_publication '127.0.0.1::80'

		assert(pub.kind_of?(YamlPublishInstructionPublication), 'publication should be of kind YamlPublishInstructionPublication')
		assert_equal('127.0.0.1', pub.ip, 'Publication has wrong ip')
		assert_equal(nil, pub.host_port, 'Publication has wrong host port')
		assert_equal(80, pub.container_port, 'Publication has wrong container port')
	end


	def test_ParseHostContainer
		pub = YamlPublishInstruction.parse_publication '8080:80'

		assert(pub.kind_of?(YamlPublishInstructionPublication), 'publication should be of kind YamlPublishInstructionPublication')
		assert_equal(nil, pub.ip, 'Publication has wrong ip')
		assert_equal(8080, pub.host_port, 'Publication has wrong host port')
		assert_equal(80, pub.container_port, 'Publication has wrong container port')
	end



	def test_ParseContainer
		pub = YamlPublishInstruction.parse_publication '80'

		assert(pub.kind_of?(YamlPublishInstructionPublication), 'publication should be of kind YamlPublishInstructionPublication')
		assert_equal(nil, pub.ip, 'Publication has wrong ip')
		assert_equal(nil, pub.host_port, 'Publication has wrong host port')
		assert_equal(80, pub.container_port, 'Publication has wrong container port')
	end
end

