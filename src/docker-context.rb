require 'fileutils'
require 'securerandom'
require 'shellwords'
require 'tmpdir'

require_relative 'id'
require_relative 'shell'



class DockerContext

	def initialize
		@directory = Dir.mktmpdir
		@dockerfile = "#{@directory}/Dockerfile"

		uid = Id.user_id
		gid = Id.group_id

		user = Id.user_name
		group = Id.group_name

		dockerfile <<-DOCKERFILE
			FROM	ubuntu:16.04

			RUN	apt-get -y update && apt-get -y install	sudo

			RUN	echo 'ALL            ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers
			RUN	groupadd --gid=#{gid} #{group}
			RUN	useradd --gid=#{gid} --uid=#{uid} --home='/home/#{user}' '#{user}'
			RUN	mkdir -p '/home/#{user}'
			RUN	chown -R '#{uid}:#{gid}' '/home/#{user}'
			USER	'#{user}'
		DOCKERFILE
	end



	def close
		FileUtils.rm_rf @directory
	end





	def dockerfile(content)
		File.open(@dockerfile, 'a:UTF-8') do |df|
			df.puts content
		end
	end



	# Build docker context
	#
	# TODO: Automatically untag the image and return the docker image
	#     identification
	#
	# @return docker image identification
	def build_image
		image_tag = 'mini-cross-' + SecureRandom.hex


		# Build docker image with temporary tag
		Shell.run Shellwords.join([
			'docker',
			'build',
			'--tag', image_tag,
			@directory
		]) or raise 'Failed building docker image'


		return image_tag
	end

end

