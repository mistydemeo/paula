require 'paula/player'
require 'paula/uade/library'

module Paula
  module UADE
    class Player < Paula::Player
      extend Paula::UADE

      detects_formats
      supports_title

      @state = uade_new_state(nil)

      def self.finalize state
        proc { uade_cleanup_state(state) }
      end

      def self.can_play? file
        uade_is_our_file(file, @state) == 0 ? false : true
      end

      def initialize file, opts
        super
        extend Paula::UADE

        @state = uade_new_state(nil)
        @config = uade_get_effective_config(@state)
        @info = UadeSongInfo.new(uade_get_song_info(@state))
        if uade_play(file, -1, @state) != 1
          raise Paula::LoadError, "could not play #{file}"
        end
        uade_config_set_option(@config, :frequency, @frequency.to_s)

        @buffer_size = 4096
        @buffer = FFI::MemoryPointer.new :char, @buffer_size
        @buffers_generated = 0

        @samples_per_millisecond = ((@frequency * 16 * 2) / 8) / 1000 / @buffer_size.to_f
      end

      def next_sample
        @buffers_generated += 1
        uade_read(@buffer, @buffer_size, @state)
        @buffer.read_bytes(@buffer_size)
      end

      def title
        @info[:modulename]
      end

      def duration
        @info[:duration] * 1000
      end

      def sample_size
        @buffer_size
      end

      def position
        @buffers_generated / @samples_per_millisecond
      end

      def complete?
        return false if duration == 0.0
        position > duration
      end

      # TODO This currently can't be returned from libuade.
      # True Amiga songs will almost always have 4 channels, but this
      # is not guaranteed.
      def channels; 4; end

      def seek time
        if !((time.is_a? Fixnum) || (time.is_a? Float))
          raise ArgumentError, "argument to #seek must be a Fixnum or Float"
        end
        if uade_seek(:song_relative, time, 0, @state) != 0
          raise "seek to #{time} failed!"
        end

        # Wait for the seek to complete
        begin; end while uade_is_seeking(@state) == 1

        true
      end
    end
  end
end
