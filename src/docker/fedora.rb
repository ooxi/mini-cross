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

require 'shellwords'

require_relative 'base'



# Specialization for Fedora like systems
class FedoraDockerContext < BaseDockerContext

	# @param id {@link Id}-like object
	# @param from Docker image to be used as base (e.g. `fedora:25')
	def initialize(id, from)
		uid = id.user_id
		gid = id.group_id

		user = id.user_name
		group = id.group_name


		df = Dockerfile.new
		df.from		from

		# Ensure unicode support
		df.run_sh	'dnf install -y glibc-locale-source'
		df.run_sh	'localedef  --force --inputfile=en_US --charmap=UTF-8 en_US.UTF-8'
		df.env		'LANG',		'en_US.UTF-8'
		df.env		'LANGUAGE',	'en_US:en'
		df.env		'LC_ALL',	'en_US.UTF-8'

		# Provide password-less sudo
		df.run_sh	'dnf install -y sudo'
		df.run_sh	"echo 'ALL            ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers"

		# Add user in context similar to host user
		df.run_exec	['groupadd', '--gid', gid, group]
		df.run_exec	['useradd', '--gid', gid, '--uid', uid, '--home', "/home/#{user}", user]
		df.run_exec	['mkdir', '-p', "/home/#{user}"]
		df.run_exec	['chown', '-R', "#{uid}:#{gid}", "/home/#{user}"]
		df.user		user

		# Choose bash as default shell
		df.cmd_exec	['/bin/bash']

		super(df)
	end



	def install(packages)
		dockerfile.run_sh "sudo dnf -y install #{Shellwords.join packages}"
	end

end

