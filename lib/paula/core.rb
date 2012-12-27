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

    # iterate through preferred players for the given file extension
    players = file.played_by(preferred: true)
    if players
      begin
        return players.shift.new(file, opts)
      rescue Paula::LoadError
      end while !players.empty?
    end

    # if that didn't succeed, see if any preferred autodetect players
    # are appropriate
    player = Paula.preferred_autodetectors.find {|p| p.can_play?(file)}
    return player.new(file, opts) if player

    # if that also didn't succeed, try the full autodetect player list
    player = Paula.autodetectors.find {|p| p.can_play?(file)}
    return player.new(file, opts) if player

    # if we still didn't find anything, look up the full player/extension map
    players = file.played_by(preferred: false)
    # raise an exception if no players were found
    # it's a reasonable guess that the significant part is a regular
    # file extension, not an Amiga-style prefix
    raise Paula::LoadError, "unrecognized filetype: #{file.suffix}" if players.nil?

    begin
      return players.shift.new(file, opts)
    rescue Paula::LoadError
    end while !players.empty?

    raise Paula::LoadError, "no appropriate player found for #{file}"
  end
end

module Paula
  @players = []
  @extension_map = {}
  @preferred = []
  @preferred_map = {}

  def self.add_formats library, extensions
    extensions.each do |ext|
      @extension_map[ext] ||= []
      @extension_map[ext] << library
    end
  end

  # This method registers a player without any associated extensions.
  # This should be used if a player defines a .can_play? method which
  # can determine if a file is appropriate.
  # It should *not* be used if the player registers file extensions.
  def self.add_player player
    @players << player
  end

  def self.prefer player
    if player.is_a? Hash
      format, player = player.shift
      @preferred_map[format] ||= []
      @preferred_map[format].unshift player
    else
      @preferred.unshift player
    end
  end

  def self.autodetectors; @players; end
  def self.preferred_autodetectors; @preferred; end

  def self.plays format, opts={}
    if opts[:preferred]
      return unless @preferred_map[format]
      @preferred_map[format].dup
    else
      return unless @extension_map[format]
      @extension_map[format].dup
    end
  end
end