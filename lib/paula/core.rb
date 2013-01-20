require 'paula/registry'
require 'paula/songfile'

module Kernel
  # Request a player object given a file and options.
  # The order in which players will be queried is:
  # 1. Preferred players by file extension
  # 2. Preferred players which autodetect formats
  # 3. Regular players which autodetect formats
  # 4. Regular players by file extension
  def Paula(file, opts)
    file = Paula::SongFile.new(file)
    player = file.find_player
    if player
      return player.new(file, opts)
    else
      raise Paula::LoadError, "no appropriate player found for #{file}"
    end
  end
end

module Paula
  CentralRegistry = Registry.new
end
