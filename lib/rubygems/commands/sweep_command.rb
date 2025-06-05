require "rbconfig"
require "pathname"
require "rubygems/command"

module GemSweep
  def self.clean(spec, aggressive: false, dryrun: false)
    (spec.full_require_paths - [spec.extension_dir]).each do |path|
      begin
        Dir.glob(File.join(path, "**/*")).each do |file|
          # Prevent deleting files in versioned directories like google-protobuf, nokogiri
          next if file.sub(/#{spec.full_gem_path}\//, "") =~ /(\d+\.\d+\/)/

          if Pathname(file).extname == ".#{RbConfig::CONFIG["DLEXT"]}"
            if dryrun
              puts "Would delete #{file}"
            else
              File.delete(file)
              puts "Delete #{file}"
            end
          end
        end
      rescue Errno::EPERM
      end
    end

    if aggressive
      clean_development_directories(spec, dryrun: dryrun)
    end
  end

  def self.clean_development_directories(spec, dryrun: false)
    %w[test spec features].each do |dir_name|
      dir_path = File.join(spec.full_gem_path, dir_name)
      remove_directory(dir_path, dryrun: dryrun) if Dir.exist?(dir_path)
    end

    Dir.glob(File.join(spec.full_gem_path, "**/tmp")).each do |tmp_dir|
      remove_directory(tmp_dir, dryrun: dryrun) if Dir.exist?(tmp_dir)
    end
  end

  def self.remove_directory(dir_path, dryrun: false)
    begin
      if dryrun
        puts "Would delete #{dir_path}/"
      else
        require "fileutils"
        FileUtils.rm_rf(dir_path)
        puts "Delete #{dir_path}/"
      end
    rescue Errno::EPERM
      puts "Permission denied: #{dir_path}/"
    end
  end
end

class Gem::Commands::SweepCommand < Gem::Command
  def initialize
    super "sweep", "Clean up unnecessary extension files"

    add_option("-a", "--aggressive", "Also remove test, spec, and features directories") do |value, options|
      options[:aggressive] = true
    end

    add_option("-n", "--dryrun", "Show what would be deleted without actually deleting") do |value, options|
      options[:dryrun] = true
    end
  end

  def execute
    aggressive = options[:aggressive]
    dryrun = options[:dryrun]

    if dryrun
      puts "Dry run mode: showing what would be deleted"
      puts
    end

    Gem::Specification.each do |spec|
      if aggressive || !spec.extensions.empty?
        GemSweep.clean(spec, aggressive: aggressive, dryrun: dryrun)
      end
    end
  end
end
