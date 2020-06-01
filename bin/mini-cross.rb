#!/usr/bin/env ruby

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

dr = context.run
dr.add_volume	config.base_directory, config.base_directory, ['rw']
dr.workdir	working_directory



# Build image and switch to docker container
image = DockerCli.build_context context
DockerCli.run image, context.run, cli.tty, cli.command

