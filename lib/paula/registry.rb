module Paula
  class Registry
    attr_accessor :players

    def initialize
      @players = []
      @extension_map = {}
      @preferred = []
      @preferred_map = {}
    end

    def add_formats library, extensions
      extensions.each do |ext|
        @extension_map[ext] ||= []
        next if @extension_map[ext].include? library
        @extension_map[ext] << library
      end
    end

    # This method registers a player without any associated extensions.
    # This should be used if a player defines a .can_play? method which
    # can determine if a file is appropriate.
    # It should *not* be used if the player registers file extensions.
    def add_player player
      @players << player unless @players.include? player
    end

    def prefer player
      if player.is_a? Hash
        format, player = player.shift
        @preferred_map[format] ||= []
        @preferred_map[format].unshift player
      else
        @preferred.unshift player
      end
    end

    def autodetectors; @players; end
    def preferred_autodetectors; @preferred; end

    def plays format, opts={}
      if opts[:preferred]
        return unless @preferred_map[format]
        @preferred_map[format].dup
      else
        return unless @extension_map[format]
        @extension_map[format].dup
      end
    end
  end
end
