require 'paula/core'
require 'paula/exceptions'
require 'paula/songfile'

module Paula
  class Player
    include Enumerable

    class << self
      def self.attr_bool *vals
        vals.each do |val|
          define_method(val) {instance_variable_set "@#{val}", true}
          define_method((val.to_s+'?').to_sym) {instance_variable_get "@#{val}"}
        end
      end

      def register_to *list
        self.registries = list
      end

      def dont_register; registries.clear; end

      def registries= list; @registries = list; end
      def registries
        @registries ||= [Paula.registry]
        @registries
      end

      attr_bool :supports_title, :supports_comment, :supports_instruments,
        :supports_notes, :supports_composer

      def maximum_frequency freq=nil
        @maximum_frequency || @maximum_frequency = freq
      end

      def extensions *ext
        return @extensions if @extensions

        registries.each {|r| r.add_formats self, ext}
        @extensions = ext
      end

      def detects_formats
        return if @detects_formats

        registries.each {|r| r.add_player self}
        @detects_formats = true
      end

      def detects_formats?; @detects_formats || false; end

      # Subclasses should override this with library-specific
      # logic if they have the ability to detect formats based on
      # something other than the extension.
      def can_play? file
        file = Paula::SongFile.new(file)
        extensions.include?(file.suffix) || extensions.include?(file.prefix)
      end
    end

    def initialize file, opts
      @filename  = Paula::SongFile.new(file)
      @loops     = opts[:loops] || 1
      @frequency = opts[:frequency]

      raise Paula::FrequencyError, "no frequency specified" unless @frequency

      # until resampling is implemented
      if self.class.maximum_frequency && @frequency > self.class.maximum_frequency
        raise Paula::FrequencyError, "#{opts[:frequency]} is greater than the maximum supported frequency of #{self.class.maximum_frequency}"
      end
    end

    # Iterates through all the samples in the current song. Note that
    # this starts from the *current* point in the song - if samples have
    # already been generated, the iteration will start from the next sample,
    # not from the start of the song.
    def each
      return to_enum unless block_given?

      begin
        yield next_sample
      end while not complete?
    end

    def path; @filename; end
    def filename; File.basename(@filename); end
    # TODO: allow the frequency to be changed after creation
    # Probably playback libraries won't allow changing frequency after playback
    # starts so this should probably be handled by resampling the rendered
    # samples instead.
    def frequency; @frequency; end
    def loops_to_play; @loops; end

    # The values for the following methods should be overridden in subclasses.

    # The title of the song. Only use this for real titles, not filenames.
    # Return nil if there is no title, even if the player supports titles.
    # When returning a string, encoding should be UTF-8.
    def title; nil; end
    # The composer of the song, if contained in the metadata. Return nil
    # if there is no composer, even if the player supports composers.
    # When returning a string, encoding should be UTF-8.
    def composer; nil; end
    # Non-title metadata about the song. You might want to generate this
    # from multiple other fields. Return nil if there is no appropriate comment.
    def comment; nil; end
    # Return the next raw audio sample in the song. Moves the internal
    # position forward.
    def next_sample; ""; end
    # The size of a sample in bytes. Should be consistent. If the value
    # is indeterminate (for example, if the player doesn't provide this
    # information until after playback starts and no sample has been
    # generated yet), you should return nil.
    def sample_size; nil; end
    # The song's total duration, if possible to estimate. Should be measured in
    # milliseconds. Should return nil if the duration is unknown.
    def duration; 0; end
    # The player's current position in the song, in milliseconds.
    # This value should be for the *current* song, even it is not the
    # first subsong.
    def position; 0; end
    def current_loop; 0; end
    # Return true if the song is finished. If the player has no internal
    # function to determine if playback is complete, it should be based on
    #
    # 1. whether the elapsed time has exceeded the song's length, if the song length is reliable,
    # 2. whether the requested number of loops have been played,
    # 3. whether the timeout period has elapsed. The default timeout is 512 seconds, but can be overridden while creating the player.
    def complete?; true; end
    # The number of channels in the current song. This might be variable
    # depending on the song, or fixed if the hardware being emulated has
    # a specific number of channels.
    def channels; 0; end
    # Seek to a position in the current song. This should be a no-op if
    # seeking of any kind is not supported.
    # The value of `time` is in milliseconds. Negative values should be
    # used to indicate seeking backwards.
    # Most players should be able to seek forward simply rendering and
    # then discarding samples until the song reaches the requested point.
    # It's acceptable for a subclass to support seeking forward, but not
    # in reverse.
    # Players should return true if seeking succeeded, and nil if nothing
    # was performed.
    def seek(time); end
  end
end
