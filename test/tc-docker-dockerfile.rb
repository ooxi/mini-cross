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

require_relative '../src/docker/dockerfile'





class TestDockerfile < Test::Unit::TestCase


	# Integration
	def test_Dockerfile
		dockerfile = Dockerfile.new
	
		dockerfile.from 'ubuntu:16.04'
		dockerfile.run_sh 'apt-get -y update && apt-get -y install sudo'

		statements = dockerfile.instance_variable_get('@statements')
		assert(2 == statements.size, "Expected exactly two statements but got #{statements.size}")

		assert_equal("FROM ubuntu:16.04\nRUN [\"/bin/bash\",\"-c\",\"apt-get -y update && apt-get -y install sudo\"]", dockerfile.to_s, 'Unexpected dockerfile contents')
	end


	def test_Cmd_Exec
		dockerfile = Dockerfile.new
		dockerfile.cmd_exec ['/bin/bash']

		statements = dockerfile.instance_variable_get('@statements')
		assert(1 == statements.size, "Expected exactly one statement but got #{statements.size}")

		statement = statements[0]
		assert(statement.kind_of?(DockerfileCmdStatement), "Expected statement \`#{statement}' to be of kind \`DockerfileCmdStatement' but is of type \`#{statement.class}'")
		assert_equal(['/bin/bash'], statement.exec)
		assert_equal('CMD ["/bin/bash"]', statement.to_s)
	end


	def test_Cmd_Sh
		dockerfile = Dockerfile.new
		dockerfile.cmd_sh 'echo "Hello World!"'

		statements = dockerfile.instance_variable_get('@statements')
		assert(1 == statements.size, "Expected exactly one statement but got #{statements.size}")

		statement = statements[0]
		assert(statement.kind_of?(DockerfileCmdStatement), "Expected statement \`#{statement}' to be of kind \`DockerfileCmdStatement' but is of type \`#{statement.class}'")
		assert_equal(['/bin/bash', '-c', 'echo "Hello World!"'], statement.exec)
		assert_equal('CMD ["/bin/bash","-c","echo \\"Hello World!\\""]', statement.to_s)
	end


	def test_Copy
		dockerfile = Dockerfile.new
		dockerfile.copy 'src', '/dest'

		statements = dockerfile.instance_variable_get('@statements')
		assert(1 == statements.size, "Expected exactly one statement but got #{statements.size}")

		statement = statements[0]
		assert(statement.kind_of?(DockerfileCopyStatement), "Expected statement \`#{statement}' to be of kind \`DockerfileCopyStatement' but is of type \`#{statement.class}'")
		assert_equal('src', statement.source)
		assert_equal('/dest', statement.destination)
		assert_equal('COPY ["src","/dest"]', statement.to_s)
	end


	def test_Env
		dockerfile = Dockerfile.new
		dockerfile.env 'MY_KEY', 'my value'

		statements = dockerfile.instance_variable_get('@statements')
		assert(1 == statements.size, "Expected exactly one statement but got #{statements.size}")

		statement = statements[0]
		assert(statement.kind_of?(DockerfileEnvStatement), "Expected statement \`#{statement}' to be of kind \`DockerfileEnvStatement' but is of type \`#{statement.class}'")
		assert_equal({'MY_KEY' => 'my value'}, statement.environment)
		assert_equal('ENV MY_KEY=my\\ value', statement.to_s)
	end


	def test_From
		dockerfile = Dockerfile.new
		dockerfile.from 'ubuntu:16.04'

		statements = dockerfile.instance_variable_get('@statements')
		assert(1 == statements.size, "Expected exactly one statement but got #{statements.size}")

		statement = statements[0]
		assert(statement.kind_of?(DockerfileFromStatement), "Expected statement \`#{statement}' to be of kind \`DockerfileFromStatement' but is of type \`#{statement.class}'")
		assert_equal('ubuntu:16.04', statement.image)
		assert_equal('FROM ubuntu:16.04', statement.to_s)
	end


	def test_Run_Exec
		dockerfile = Dockerfile.new
		dockerfile.run_exec ['/bin/bash']

		statements = dockerfile.instance_variable_get('@statements')
		assert(1 == statements.size, "Expected exactly one statement but got #{statements.size}")

		statement = statements[0]
		assert(statement.kind_of?(DockerfileRunStatement), "Expected statement \`#{statement}' to be of kind \`DockerfileRunStatement' but is of type \`#{statement.class}'")
		assert_equal(['/bin/bash'], statement.exec)
		assert_equal('RUN ["/bin/bash"]', statement.to_s)
	end


	def test_Exec_Sh
		dockerfile = Dockerfile.new
		dockerfile.run_sh 'echo "Hello World!"'

		statements = dockerfile.instance_variable_get('@statements')
		assert(1 == statements.size, "Expected exactly one statement but got #{statements.size}")

		statement = statements[0]
		assert(statement.kind_of?(DockerfileRunStatement), "Expected statement \`#{statement}' to be of kind \`DockerfileRunStatement' but is of type \`#{statement.class}'")
		assert_equal(['/bin/bash', '-c', 'echo "Hello World!"'], statement.exec)
		assert_equal('RUN ["/bin/bash","-c","echo \\"Hello World!\\""]', statement.to_s)
	end


	def test_User
		dockerfile = Dockerfile.new
		dockerfile.user 'my-user'

		statements = dockerfile.instance_variable_get('@statements')
		assert(1 == statements.size, "Expected exactly one statement but got #{statements.size}")

		statement = statements[0]
		assert(statement.kind_of?(DockerfileUserStatement), "Expected statement \`#{statement}' to be of kind \`DockerfileUserStatement' but is of type \`#{statement.class}'")
		assert_equal('my-user', statement.user)
		assert_equal('USER my-user', statement.to_s)
	end


	def test_Volume
		dockerfile = Dockerfile.new
		dockerfile.volume '/var/lib/svn'

		statements = dockerfile.instance_variable_get('@statements')
		assert(1 == statements.size, "Expected exactly one statement but got #{statements.size}")

		statement = statements[0]
		assert(statement.kind_of?(DockerfileVolumeStatement), "Expected statement \`#{statement}' to be of kind \`DockerfileVolumeStatement' but is of type \`#{statement.class}'")
		assert_equal(['/var/lib/svn'], statement.volumes)
		assert_equal('VOLUME ["/var/lib/svn"]', statement.to_s)
	end


	def test_Volumes
		dockerfile = Dockerfile.new
		dockerfile.volumes ['/var/lib/git', '/var/lib/svn']

		statements = dockerfile.instance_variable_get('@statements')
		assert(1 == statements.size, "Expected exactly one statement but got #{statements.size}")

		statement = statements[0]
		assert(statement.kind_of?(DockerfileVolumeStatement), "Expected statement \`#{statement}' to be of kind \`DockerfileVolumeStatement' but is of type \`#{statement.class}'")
		assert_equal(['/var/lib/git', '/var/lib/svn'], statement.volumes)
		assert_equal('VOLUME ["/var/lib/git","/var/lib/svn"]', statement.to_s)
	end


	def test_Workdir
		dockerfile = Dockerfile.new
		dockerfile.workdir '/home/user name/'

		statements = dockerfile.instance_variable_get('@statements')
		assert(1 == statements.size, "Expected exactly one statement but got #{statements.size}")

		statement = statements[0]
		assert(statement.kind_of?(DockerfileWorkdirStatement), "Expected statement \`#{statement}' to be of kind \`DockerfileWorkdirStatement' but is of type \`#{statement.class}'")
		assert_equal('/home/user name/', statement.workdir)
		assert_equal('WORKDIR /home/user\\ name/', statement.to_s)
	end

end

