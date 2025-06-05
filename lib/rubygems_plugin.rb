require "rubygems/commands/sweep_command"
require "rubygems/command_manager"

Gem::CommandManager.instance.register_command :sweep

Gem.post_install do |installer|
  GemSweep.clean(installer.spec)
end
