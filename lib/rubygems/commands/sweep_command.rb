require "rbconfig"
require "pathname"
require "rubygems/command"

module GemSweep
  def self.clean(spec, aggressive: false, dryrun: false)
    targets = collect_cleanup_targets(spec, aggressive: aggressive)
    remove_targets(targets, dryrun: dryrun)
  end

  def self.collect_cleanup_targets(spec, aggressive: false)
    targets = []

    # Collect extension files
    (spec.full_require_paths - [spec.extension_dir]).each do |path|
      begin
        Dir.glob(File.join(path, "**/*")).each do |file|
          # Prevent deleting files in versioned directories like google-protobuf, nokogiri
          next if file.sub(/#{spec.full_gem_path}\//, "") =~ /(\d+\.\d+\/)/

          if Pathname(file).extname == ".#{RbConfig::CONFIG["DLEXT"]}"
            targets << file
          end
        end
      rescue Errno::EPERM
      end
    end

    # Collect development directories if aggressive mode
    if aggressive
      # Collect test/spec/features directories
      %w[test spec features].each do |dir_name|
        dir_path = File.join(spec.full_gem_path, dir_name)
        targets << dir_path if Dir.exist?(dir_path)
      end

      # Collect tmp directories recursively
      begin
        Dir.glob(File.join(spec.full_gem_path, "**/tmp")).each do |tmp_dir|
          targets << tmp_dir if Dir.exist?(tmp_dir)
        end
      rescue Errno::EPERM
      end
    end

    targets
  end

  def self.uninstall_missing_extensions(dryrun: false)
    specs = Gem::Specification.select do |spec|
      spec.missing_extensions?
    end

    if specs.empty?
      puts "No gems with missing extensions found"
      return
    end

    require "rubygems/uninstaller"

    specs.each do |spec|
      if dryrun
        puts "Would uninstall #{spec.full_name} (missing extensions)"
      else
        begin
          uninstaller = Gem::Uninstaller.new(spec.name, version: spec.version, executables: true)
          uninstaller.uninstall
          puts "Uninstalled #{spec.full_name} (missing extensions)"
        rescue Gem::InstallError, Gem::FilePermissionError => e
          puts "Could not uninstall #{spec.full_name}: #{e.message}"
        end
      end
    end
  end

  def self.remove_targets(targets, dryrun: false)
    targets.each do |path|
      begin
        if dryrun
          puts "Would delete #{path}#{Dir.exist?(path) ? '/' : ''}"
        else
          require "fileutils"
          FileUtils.rm_rf(path)
          puts "Delete #{path}#{Dir.exist?(path) ? '/' : ''}"
        end
      rescue Errno::EPERM
        puts "Permission denied: #{path}#{Dir.exist?(path) ? '/' : ''}"
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

    add_option("-n", "--dryrun", "Show what would be deleted without actually deleting") do |value, options|
      options[:dryrun] = true
    end

    add_option("--missing-extensions", "Uninstall gems with missing C extensions") do |value, options|
      options[:missing_extensions] = true
    end
  end

  def execute
    aggressive = options[:aggressive]
    dryrun = options[:dryrun]

    if dryrun
      puts "Dry run mode: showing what would be deleted"
      puts
    end

    if options[:missing_extensions]
      GemSweep.uninstall_missing_extensions(dryrun: dryrun)
    else
      Gem::Specification.each do |spec|
        if aggressive || !spec.extensions.empty?
          GemSweep.clean(spec, aggressive: aggressive, dryrun: dryrun)
        end
      end
    end
  end
end
