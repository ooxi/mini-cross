#!/usr/bin/env ruby
#
# @author ooxi

require 'pathname'

require_relative '../src/docker-context'
require_relative '../src/id'



def minicross_bin_directory
	file = Pathname.new(__FILE__).realpath
	directory = File.dirname(file)
	return File.expand_path directory
end


# TODO: this must be configurable by command line
def minicross_lib_directory
	directory = File.join(minicross_bin_directory, '../lib')
	return File.expand_path directory
end


def minicross_working_directory
	return File.expand_path Dir.pwd
end




#puts minicross_bin_directory
#puts minicross_lib_directory
#puts minicross_working_directory


begin
	dc = DockerContext.new
	dc.dockerfile <<-DOCKERFILE
		RUN	mkdir -p '#{minicross_working_directory}'
		WORKDIR	'#{minicross_working_directory}'
		VOLUME	'#{minicross_working_directory}'
	DOCKERFILE
	docker_image = dc.build_image
ensure
	dc.close if dc
end


exec("docker run -it --rm --user='#{Id.user_id}:#{Id.group_id}' --volume '#{minicross_working_directory}:#{minicross_working_directory}' #{docker_image}")

