require 'fileutils'
require 'test/unit'
require 'tmpdir'

require_relative '../src/find-configuration'




 
class TestFindConfiguration < Test::Unit::TestCase


	# Should find $dir/.mc/mc.yaml
	def test_FindUnnamedConfigurationInSubdirectory
		Dir.mktmpdir do |dir|
			FileUtils.mkdir_p("#{dir}/.mc")
			File.write("#{dir}/.mc/mc.yaml", 'found')

			config = FindConfiguration.without_name(dir)
			assert_not_nil(config, 'Failed finding unnamed configuration .mc/mc.yaml')

			assert_equal('found', File.read(config), 'Unexpected configuration content')
		end
	end


	# Should find $dir/mc.yaml
	def test_FindUnnamedConfigurationInCurrentDirectory
		Dir.mktmpdir do |dir|
			File.write("#{dir}/mc.yaml", 'found')

			config = FindConfiguration.without_name(dir)
			assert_not_nil(config, 'Failed finding unnamed configuration mc.yaml')

			assert_equal('found', File.read(config), 'Unexpected configuration content')
		end
	end


	# Should find $dir/../.mc/mc.yaml
	def test_FindUnnamedConfigurationInSubdirectoryOfParentDirectory
		Dir.mktmpdir do |dir|
			FileUtils.mkdir_p("#{dir}/src/some/project/")
			FileUtils.mkdir_p("#{dir}/src/.mc/")
			File.write("#{dir}/src/.mc/mc.yaml", 'found')

			config = FindConfiguration.without_name("#{dir}/src/some/project/")
			assert_not_nil(config, 'Failed finding unnamed configuration .mc/mc.yaml in parent directory')

			assert_equal('found', File.read(config), 'Unexpected configuration content')
		end
	end


	# Should find $dir/../mc.yaml
	def test_FindUnnamedConfigurationInParentDirectory
		Dir.mktmpdir do |dir|
			FileUtils.mkdir_p("#{dir}/src/some/project/")
			File.write("#{dir}/src/mc.yaml", 'found')

			config = FindConfiguration.without_name("#{dir}/src/some/project/")
			assert_not_nil(config, 'Failed finding unnamed configuration mc.yaml in parent directory')

			assert_equal('found', File.read(config), 'Unexpected configuration content')
		end
	end


	# Should not find any configuration
	def test_CannotFindUnnamedConfiguration
		Dir.mktmpdir do |dir|
			config = FindConfiguration.without_name(dir)
			assert_nil(config, "Should not have found configuration but found #{config}")
		end
	end





	# Should find $dir/.mc/machine/machine.yaml
	def test_FindNamedConfigurationWithContext
		Dir.mktmpdir do |dir|
			FileUtils.mkdir_p("#{dir}/.mc/machine")
			File.write("#{dir}/.mc/machine/machine.yaml", 'found')

			config = FindConfiguration.named(dir, 'machine')
			assert_not_nil(config, 'Failed finding unnamed configuration .mc/machine/machine.yaml')

			assert_equal('found', File.read(config), 'Unexpected configuration content')
		end
	end


	# Should find $dir/.mc/machine.yaml
	def test_FindNamedConfigurationWithoutContext
		Dir.mktmpdir do |dir|
			FileUtils.mkdir_p("#{dir}/.mc")
			File.write("#{dir}/.mc/machine.yaml", 'found')

			config = FindConfiguration.named(dir, 'machine')
			assert_not_nil(config, 'Failed finding unnamed configuration .mc/machine.yaml')

			assert_equal('found', File.read(config), 'Unexpected configuration content')
		end
	end


	# Should find $dir/machine.yaml
	def test_FindNamedConfigurationWithoutContextInCurrentDirectory
		Dir.mktmpdir do |dir|
			File.write("#{dir}/machine.yaml", 'found')

			config = FindConfiguration.named(dir, 'machine')
			assert_not_nil(config, 'Failed finding unnamed configuration machine.yaml')

			assert_equal('found', File.read(config), 'Unexpected configuration content')
		end
	end


	# Should find $dir/../.mc/machine/machine.yaml
	def test_FindNamedConfigurationWithContextInParentDirectory
		Dir.mktmpdir do |dir|
			FileUtils.mkdir_p("#{dir}/src/some/project/")
			FileUtils.mkdir_p("#{dir}/src/.mc/machine/")
			File.write("#{dir}/src/.mc/machine/machine.yaml", 'found')

			config = FindConfiguration.named("#{dir}/src/some/project/", 'machine')
			assert_not_nil(config, 'Failed finding unnamed configuration .mc/machine/machine.yaml in parent directory')

			assert_equal('found', File.read(config), 'Unexpected configuration content')
		end
	end


	# Should find $dir/../.mc/machine.yaml
	def test_FindNamedConfigurationWithoutContextInParentDirectory
		Dir.mktmpdir do |dir|
			FileUtils.mkdir_p("#{dir}/src/some/project/")
			FileUtils.mkdir_p("#{dir}/src/.mc/")
			File.write("#{dir}/src/.mc/machine.yaml", 'found')

			config = FindConfiguration.named("#{dir}/src/some/project/", 'machine')
			assert_not_nil(config, 'Failed finding unnamed configuration .mc/machine.yaml in parent directory')

			assert_equal('found', File.read(config), 'Unexpected configuration content')
		end
	end


	# Should not find any configuration
	def test_CannotFindNamedConfiguration
		Dir.mktmpdir do |dir|
			config = FindConfiguration.named(dir, 'machine')
			assert_nil(config, "Should not have found configuration but found #{config}")
		end
	end





	# Should find $dir/.mc
	def test_FindUnnamedContext
		Dir.mktmpdir do |dir|
			FileUtils.mkdir_p("#{dir}/.mc")
			File.write("#{dir}/.mc/mc.yaml", 'found')

			context = FindConfiguration.context("#{dir}/.mc/mc.yaml")
			assert_not_nil(context, 'Failed finding unnamed context .mc/')

			assert_equal("#{dir}/.mc", context, "Found unexpected context #{context}")
		end
	end


	# Should find $dir/.mc/machine
	def test_FindNamedContext
		Dir.mktmpdir do |dir|
			FileUtils.mkdir_p("#{dir}/.mc/machine")
			File.write("#{dir}/.mc/machine/machine.yaml", 'found')

			context = FindConfiguration.context("#{dir}/.mc/machine/machine.yaml")
			assert_not_nil(context, 'Failed finding named context .mc/machine')

			assert_equal("#{dir}/.mc/machine", context, "Found unexpected context #{context}")
		end
	end
end

