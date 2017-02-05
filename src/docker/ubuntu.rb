require 'shellwords'

require_relative 'base'



# Specialization for Ubuntu like systems
class UbuntuDockerContext < BaseDockerContext

	# @param id {@link Id}-like object
	# @param from Docker image to be used as base (e.g. `ubuntu:16.04')
	def initialize(id, from)
		uid = id.user_id
		gid = id.group_id

		user = id.user_name
		group = id.group_name

		dockerfile = <<-DOCKERFILE
			FROM	#{from}

			# Ensure unicode support
			RUN locale-gen en_US.UTF-8
			ENV LANG en_US.UTF-8
			ENV LANGUAGE en_US:en
			ENV LC_ALL en_US.UTF-8

			# Provide password-less sudo
			RUN	apt-get -y update && apt-get -y install	sudo
			RUN	echo 'ALL            ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers

			# Add user in context similar to host user
			RUN	groupadd --gid=#{gid} #{group}
			RUN	useradd --gid=#{gid} --uid=#{uid} --home='/home/#{user}' '#{user}'
			RUN	mkdir -p '/home/#{user}'
			RUN	chown -R '#{uid}:#{gid}' '/home/#{user}'
			USER	'#{user}'
		DOCKERFILE

		super(dockerfile)
	end



	def install(packages)
		dockerfile <<-DOCKERFILE
			RUN	sudo apt-get -y update && sudo apt-get -y install #{Shellwords.join packages}
		DOCKERFILE
	end

end

