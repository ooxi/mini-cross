require 'digest'
require 'fileutils'
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



	# Build docker context.
	#
	# Will use the Dockerfile contents as image identification. This might
	# result in multiple images using the same tag when differentiated only
	# by contents of the context directories. Nevertheless this should be
	# the exception, not the general case.
	#
	# @return docker image identification
	def build_image
		hash = Digest::SHA256.file @dockerfile
		image_tag = 'mini-cross-' + hash.hexdigest


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

