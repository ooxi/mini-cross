#!/usr/bin/env ruby
#
# @author ooxi

require_relative '../src/cli'
require_relative '../src/docker-cli'
require_relative '../src/docker/fedora'
require_relative '../src/docker/ubuntu'
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
dc = FedoraDockerContext.new(Id.real, 'fedora:25')
#dc = UbuntuDockerContext.new(Id.real, 'ubuntu:16.04')

dc.dockerfile <<-DOCKERFILE
	RUN	mkdir -p '#{config.base_directory}'
	VOLUME	'#{config.base_directory}'
	WORKDIR	'#{working_directory}'
DOCKERFILE



# Build image and switch to docker container
image = DockerCli.build_context dc
DockerCli.run Id.real, image, config.base_directory, cli.command

