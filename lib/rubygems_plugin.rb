require "gem-sweep"
require "rubygems/command_manager"

class Gem::Commands::SweepCommand < Gem::Command
  def initialize
    super "sweep", "Clean up unnecessary extension files"
  end

  def execute
    Gem::Specification.each do |spec|
      next if spec.extensions.empty?
      GemSweep.clean(spec)
    end
  end
end

Gem::CommandManager.instance.register_command :sweep

Gem.post_install do |installer|
  GemSweep.clean(installer.spec)
end
