require 'paula/exceptions'

module Paula
  class Player

    class << self
      def self.attr_bool *vals
        vals.each do |val|
          define_method(val) {instance_variable_set "@#{val}", true}
          define_method((val.to_s+'?').to_sym) {instance_variable_get "@#{val}"}
        end
      end

      attr_bool :supports_title, :supports_comment, :supports_instruments,
        :supports_notes

      def maximum_frequency freq=nil
        @maximum_frequency || @maximum_frequency = freq
      end

      def extensions ext=nil
        ext = [ext] unless ext.is_a? Array
        @extensions || @extensions = ext
      end

      def can_play? file
        extension = File.extname(file)[1..-1].downcase
        prefix = File.basename(file, File.extname(file)).downcase
        extensions.include?(extension) || extensions.include?(prefix)
      end
    end

    def initialize file, opts
      @filename  = file
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
    # Return nil if there is no filename, even if the player supports names.
    # When returning a string, encoding should be UTF-8.
    def title; nil; end
    # Non-title metadata about the song. You might want to generate this
    # from multiple other fields. Return nil if there is no appropriate comment.
    def comment; nil; end
    # Return the next raw audio sample in the song. Moves the internal
    # position forward.
    def next_sample; ""; end
    # The size of a sample in bytes. Should be consistent.
    def sample_size; 0; end
    # The song's total duration, if possible to estimate. Should be measured in
    # milliseconds. Should return nil if the duration is unknown.
    def duration; 0; end
    def current_loop; 0; end
    # Return true if the song is finished. If the player has no internal
    # function to determine if playback is complete, it should be based on
    # a) whether the elapsed time has exceeded the song's length, if the
    #    song length is reliable,
    # b) whether the requested number of loops have been played,
    # c) whether the timeout period has elapsed. The default timeout is
    #    512 seconds, but can be overridden while creating the player.
    def complete?; true; end
  end
end
