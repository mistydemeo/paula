require 'pathname'

module Paula
  class SongFile
    # By default, a SongFile will find players for itself from the
    # central registry. This can be overridden via #registry=
    attr_accessor :registry

    def initialize file
      @file = Pathname(File.expand_path file)
      @registry = Paula::CentralRegistry
    end

    def prefix
      @file.basename(@file.extname).to_s.downcase
    end

    def suffix
      @file.extname[1..-1].to_s.downcase
    end

    def played_by opts={preferred: false}
      @registry.plays(suffix, opts) || @registry.plays(prefix, opts)
    end

    # Attempts to find a player class which can play the SongFile.
    # Returns nil if no appropriate class could be found.
    def find_player
      # iterate through preferred players for the given file extension
      players = played_by(preferred: true)
      if players
        begin
          return players.shift
        rescue Paula::LoadError
        end while !players.empty?
      end

      # if that didn't succeed, see if any preferred autodetect players
      # are appropriate
      player = @registry.preferred_autodetectors.find {|p| p.can_play?(self)}
      return player if player

      # if that also didn't succeed, try the full autodetect player list
      player = @registry.autodetectors.find {|p| p.can_play?(self)}
      return player if player

      # if we still didn't find anything, look up the full player/extension map
      players = played_by(preferred: false)
      return unless players

      begin
        return players.shift
      rescue Paula::LoadError
      end while !players.empty?
    end

    def to_s; @file.to_s; end
    def to_str; @file.to_s; end
    def to_pn; @file; end
    def dirname; @file.dirname.to_s; end
    def exist?; @file.exist?; end
    def size; @file.size; end
  end
end
