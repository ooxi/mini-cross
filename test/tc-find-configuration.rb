require 'fileutils'
require 'test/unit'
require 'tmpdir'

require_relative '../src/configuration'
require_relative '../src/find-configuration'




 
class TestFindConfiguration < Test::Unit::TestCase


	# Should find
	#
	#  - yaml	$dir/.mc/mc.yaml
	#  - context	$dir/.mc/
	#  - base	$dir/
	def test_FindUnnamedConfigurationInSubdirectory
		Dir.mktmpdir do |dir|
			FileUtils.mkdir_p("#{dir}/.mc")

			File.write("#{dir}/.mc/mc.yaml", 'Yaml')
			File.write("#{dir}/.mc/context", 'Context')
			File.write("#{dir}/base", 'Base')

			config = FindConfiguration.without_name(dir)
			assert_not_nil(config, 'Failed finding unnamed configuration .mc/mc.yaml')
			assert(config.kind_of?(Configuration), 'Return value must be of type Configuration')

			assert_equal('Yaml', File.read(config.yaml_file), 'Unexpected configuration content')
			assert_equal('Context', File.read(config.context_directory + 'context'), 'Unexpected context content')
			assert_equal('Base', File.read(config.base_directory + 'base'), 'Unexpected base content')
		end
	end


	# Should find
	#
	#  - yaml	$dir/mc.yaml
	#  - context	nil
	#  - base	$dir/
	def test_FindUnnamedConfigurationInCurrentDirectory
		Dir.mktmpdir do |dir|
			File.write("#{dir}/mc.yaml", 'Yaml')
			File.write("#{dir}/base", 'Base')

			config = FindConfiguration.without_name(dir)
			assert_not_nil(config, 'Failed finding unnamed configuration mc.yaml')
			assert(config.kind_of?(Configuration), 'Return value must be of type Configuration')

			assert_equal('Yaml', File.read(config.yaml_file), 'Unexpected configuration content')
			assert_nil(config.context_directory, "Should not find context directory but found #{config.context_directory}")
			assert_equal('Base', File.read(config.base_directory + 'base'), 'Unexpected base content')
		end
	end


	# Should find
	#
	#  - yaml	$dir/../.mc/mc.yaml
	#  - context	$dir/../.mc/
	#  - base	$dir/../
	def test_FindUnnamedConfigurationInSubdirectoryOfParentDirectory
		Dir.mktmpdir do |dir|
			FileUtils.mkdir_p("#{dir}/src/some/project/")
			FileUtils.mkdir_p("#{dir}/src/.mc/")

			File.write("#{dir}/src/.mc/mc.yaml", 'Yaml')
			File.write("#{dir}/src/.mc/context", 'Context')
			File.write("#{dir}/src/base", 'Base')

			config = FindConfiguration.without_name("#{dir}/src/some/project/")
			assert_not_nil(config, 'Failed finding unnamed configuration .mc/mc.yaml in parent directory')
			assert(config.kind_of?(Configuration), 'Return value must be of type Configuration')

			assert_equal('Yaml', File.read(config.yaml_file), 'Unexpected configuration content')
			assert_equal('Context', File.read(config.context_directory + 'context'), 'Unexpected context content')
			assert_equal('Base', File.read(config.base_directory + 'base'), 'Unexpected base content')
		end
	end


	# Should find
	#
	#  - yaml	$dir/../mc.yaml
	#  - context	nil
	#  - base	$dir/../
	def test_FindUnnamedConfigurationInParentDirectory
		Dir.mktmpdir do |dir|
			FileUtils.mkdir_p("#{dir}/src/some/project/")

			File.write("#{dir}/src/mc.yaml", 'Yaml')
			File.write("#{dir}/src/base", 'Base')

			config = FindConfiguration.without_name("#{dir}/src/some/project/")
			assert_not_nil(config, 'Failed finding unnamed configuration mc.yaml in parent directory')
			assert(config.kind_of?(Configuration), 'Return value must be of type Configuration')

			assert_equal('Yaml', File.read(config.yaml_file), 'Unexpected configuration content')
			assert_nil(config.context_directory, "Should not find context directory but found #{config.context_directory}")
			assert_equal('Base', File.read(config.base_directory + 'base'), 'Unexpected base content')
		end
	end


	# Should not find any configuration
	def test_CannotFindUnnamedConfiguration
		Dir.mktmpdir do |dir|
			config = FindConfiguration.without_name(dir)
			assert_nil(config, "Should not have found configuration but found #{config}")
		end
	end





	# Should find
	#
	#  - yaml	$dir/.mc/machine/machine.yaml
	#  - context	$dir/.mc/machine/
	#  - base	$dir/
	def test_FindNamedConfigurationWithContext
		Dir.mktmpdir do |dir|
			FileUtils.mkdir_p("#{dir}/.mc/machine")

			File.write("#{dir}/.mc/machine/machine.yaml", 'Yaml')
			File.write("#{dir}/.mc/machine/context", 'Context')
			File.write("#{dir}/base", 'Base')

			config = FindConfiguration.named(dir, 'machine')
			assert_not_nil(config, 'Failed finding unnamed configuration .mc/machine/machine.yaml')
			assert(config.kind_of?(Configuration), 'Return value must be of type Configuration')

			assert_equal('Yaml', File.read(config.yaml_file), 'Unexpected configuration content')
			assert_equal('Context', File.read(config.context_directory + 'context'), 'Unexpected context content')
			assert_equal('Base', File.read(config.base_directory + 'base'), 'Unexpected base content')
		end
	end


	# Should find
	#
	#  - yaml	$dir/.mc/machine.yaml
	#  - context	nil
	#  - base	$dir/
	def test_FindNamedConfigurationWithoutContext
		Dir.mktmpdir do |dir|
			FileUtils.mkdir_p("#{dir}/.mc")

			File.write("#{dir}/.mc/machine.yaml", 'Yaml')
			File.write("#{dir}/base", 'Base')

			config = FindConfiguration.named(dir, 'machine')
			assert_not_nil(config, 'Failed finding unnamed configuration .mc/machine.yaml')
			assert(config.kind_of?(Configuration), 'Return value must be of type Configuration')

			assert_equal('Yaml', File.read(config.yaml_file), 'Unexpected configuration content')
			assert_nil(config.context_directory, "Should not find context directory but found #{config.context_directory}")
			assert_equal('Base', File.read(config.base_directory + 'base'), 'Unexpected base content')
		end
	end


	# Should find
	#
	#  - yaml	$dir/machine.yaml
	#  - context	nil
	#  - base	$dir/
	def test_FindNamedConfigurationWithoutContextInCurrentDirectory
		Dir.mktmpdir do |dir|
			File.write("#{dir}/machine.yaml", 'Yaml')
			File.write("#{dir}/base", 'Base')

			config = FindConfiguration.named(dir, 'machine')
			assert_not_nil(config, 'Failed finding unnamed configuration machine.yaml')
			assert(config.kind_of?(Configuration), 'Return value must be of type Configuration')

			assert_equal('Yaml', File.read(config.yaml_file), 'Unexpected configuration content')
			assert_nil(config.context_directory, "Should not find context directory but found #{config.context_directory}")
			assert_equal('Base', File.read(config.base_directory + 'base'), 'Unexpected base content')
		end
	end


	# Should find
	#
	#  - yaml	$dir/../.mc/machine/machine.yaml
	#  - context	$dir/../.mc/machine/
	#  - base	$dir/../
	def test_FindNamedConfigurationWithContextInParentDirectory
		Dir.mktmpdir do |dir|
			FileUtils.mkdir_p("#{dir}/src/some/project/")
			FileUtils.mkdir_p("#{dir}/src/.mc/machine/")

			File.write("#{dir}/src/.mc/machine/machine.yaml", 'Yaml')
			File.write("#{dir}/src/.mc/machine/context", 'Context')
			File.write("#{dir}/src/base", 'Base')

			config = FindConfiguration.named("#{dir}/src/some/project/", 'machine')
			assert_not_nil(config, 'Failed finding unnamed configuration .mc/machine/machine.yaml in parent directory')
			assert(config.kind_of?(Configuration), 'Return value must be of type Configuration')

			assert_equal('Yaml', File.read(config.yaml_file), 'Unexpected configuration content')
			assert_equal('Context', File.read(config.context_directory + 'context'), 'Unexpected context content')
			assert_equal('Base', File.read(config.base_directory + 'base'), 'Unexpected base content')
		end
	end


	# Should find
	#
	#  - yaml	$dir/../.mc/machine.yaml
	#  - context	nil
	#  - base	$dir/../
	def test_FindNamedConfigurationWithoutContextInParentDirectory
		Dir.mktmpdir do |dir|
			FileUtils.mkdir_p("#{dir}/src/some/project/")
			FileUtils.mkdir_p("#{dir}/src/.mc/")

			File.write("#{dir}/src/.mc/machine.yaml", 'Yaml')
			File.write("#{dir}/src/base", 'Base')

			config = FindConfiguration.named("#{dir}/src/some/project/", 'machine')
			assert_not_nil(config, 'Failed finding unnamed configuration .mc/machine.yaml in parent directory')
			assert(config.kind_of?(Configuration), 'Return value must be of type Configuration')

			assert_equal('Yaml', File.read(config.yaml_file), 'Unexpected configuration content')
			assert_nil(config.context_directory, "Should not find context directory but found #{config.context_directory}")
			assert_equal('Base', File.read(config.base_directory + 'base'), 'Unexpected base content')
		end
	end


	# Should not find any configuration
	def test_CannotFindNamedConfiguration
		Dir.mktmpdir do |dir|
			config = FindConfiguration.named(dir, 'machine')
			assert_nil(config, "Should not have found configuration but found #{config}")
		end
	end

end

