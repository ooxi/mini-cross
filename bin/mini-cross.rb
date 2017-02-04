#!/usr/bin/env ruby
#
# @author ooxi

require 'pathname'
require 'shellwords'

require_relative '../src/cli'
require_relative '../src/docker-context'
require_relative '../src/find-configuration'
require_relative '../src/id'





# Provide working directory of mini-cross invocation
def working_directory
	return File.expand_path Dir.pwd
end





# Parse command line invocation
cli = Cli.new ARGV



# Find configuration
config = if cli.machine.nil?
	FindConfiguration.without_name working_directory
else
	FindConfiguration.named working_directory, cli.machine
end

if config.nil?
	STDERR.puts "Cannot find mini-cross configuration anywhere near #{working_directory}"
	exit 1
end



# Prepare docker context
begin
	dc = DockerContext.new
	dc.dockerfile <<-DOCKERFILE
		RUN	mkdir -p '#{config.base_directory}'
		VOLUME	'#{config.base_directory}'
		WORKDIR	'#{working_directory}'
	DOCKERFILE

	docker_image = dc.build_image
ensure
	dc.close if dc
end



# Switch to docker container
exec(Shellwords.join([
	'docker',
	'run',
	'-it',
	'--rm',
	'--user', "#{Id.user_id}:#{Id.group_id}",
	'--volume', "#{config.base_directory}:#{config.base_directory}",
	"#{docker_image}"
] + cli.command))

