require "rbconfig"
require "pathname"
require "rubygems/command"

module GemSweep
  def self.clean(spec, aggressive: false)
    (spec.full_require_paths - [spec.extension_dir]).each do |path|
      begin
        Dir.glob(File.join(path, "**/*")).each do |file|
          # Prevent deleting files in versioned directories like google-protobuf, nokogiri
          next if file.sub(/#{spec.full_gem_path}\//, "") =~ /(\d+\.\d+\/)/

          if Pathname(file).extname == ".#{RbConfig::CONFIG["DLEXT"]}"
            File.delete(file)
            puts "Delete #{file}"
          end
        end
      rescue Errno::EPERM
      end
    end

    if aggressive
      clean_test_directories(spec)
    end
  end

  def self.clean_test_directories(spec)
    %w[test spec features].each do |dir_name|
      test_dir = File.join(spec.full_gem_path, dir_name)
      if Dir.exist?(test_dir)
        begin
          require "fileutils"
          FileUtils.rm_rf(test_dir)
          puts "Delete #{test_dir}/"
        rescue Errno::EPERM
          puts "Permission denied: #{test_dir}/"
        end
      end
    end
  end
end

class Gem::Commands::SweepCommand < Gem::Command
  def initialize
    super "sweep", "Clean up unnecessary extension files"
    
    add_option("-a", "--aggressive", "Also remove test, spec, and features directories") do |value, options|
      options[:aggressive] = true
    end
  end

  def execute
    aggressive = options[:aggressive]
    
    Gem::Specification.each do |spec|
      if aggressive || !spec.extensions.empty?
        GemSweep.clean(spec, aggressive: aggressive)
      end
    end
  end
end
