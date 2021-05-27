# Copyright (c) 2019 github/ooxi
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

require 'shellwords'

require_relative 'base'
require_relative 'docker-run-arguments'
require_relative 'dockerfile'



# Specialization for Arch Linux like systems
class ArchDockerContext < BaseDockerContext

	# @param id {@link Id}-like object
	# @param from Docker image to be used as base (e.g. `archlinux:base')
	def initialize(id, from)
		uid = id.user_id
		gid = id.group_id

		user = id.user_name
		group = id.group_name


		df = Dockerfile.new
		df.from		from

		# Provide password-less sudo
		df.run_sh	'pacman --sync --refresh --noconfirm sudo'
		df.run_sh	"echo 'ALL            ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers"

		# Add user in context similar to host user
		df.run_exec	['groupadd', '--gid', gid, group]
		df.run_exec	['useradd', '--gid', gid, '--uid', uid, '--home', "/home/#{user}", user]
		df.run_exec	['mkdir', '-p', "/home/#{user}"]
		df.run_exec	['chown', '-R', "#{uid}:#{gid}", "/home/#{user}"]
		df.user		user

		# Choose bash as default shell
		df.cmd_exec	['/bin/bash']


		dr = DockerRunArguments.new
		dr.user		id


		super(df, dr)
	end



	def install(packages)
		dockerfile.run_sh "sudo pacman --sync --refresh --noconfirm #{Shellwords.join packages}"
	end

end

