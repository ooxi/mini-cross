#!/usr/bin/env ruby
#
# @author ooxi

require_relative '../src/cli'
require_relative '../src/docker-cli'
require_relative '../src/docker/factory'
require_relative '../src/find-configuration'
require_relative '../src/id'
require_relative '../src/yaml/configuration-parser'





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



# Transfrom configuration to set of instructions
instructions = YamlConfigurationParser.parse config

if instructions.base.nil?
	STDERR.puts "Missing base instruction! Try adding \`base: ubuntu:16.04'"
	exit 1
end


# Create and prepare docker context as instructed by configuration
context_factory = DockerContextFactory.new Id.real

context = context_factory.from_specification instructions.base
instructions.apply_to context

context.dockerfile <<-DOCKERFILE
	RUN	mkdir -p '#{config.base_directory}'
	VOLUME	'#{config.base_directory}'
	WORKDIR	'#{working_directory}'
DOCKERFILE



# Build image and switch to docker container
image = DockerCli.build_context context
DockerCli.run Id.real, image, config.base_directory, cli.command

