require 'paula/player'

module Paula
  module GME
    class Player < Paula::Player
      extend Paula::GME

      extensions *%w[vgm gym spc sap nsfe nsf ay gbs hes kss]
      supports_comment
      supports_composer
      supports_title

      def initialize file, opts
        super
        extend Paula::GME

        ptr = FFI::MemoryPointer.new(:pointer)
        gme_open_file(file, ptr, @frequency)
        @player = ptr.read_pointer
        gme_start_track(@player, 0)

        ptr = FFI::MemoryPointer.new(:pointer)
        gme_track_info(@player, ptr, 0)
        @info = GmeInfoT.new(ptr.read_pointer)

        @buffer_size = 4096
        @buffer = FFI::MemoryPointer.new :short, @buffer_size
        @buffers_generated = 0
        @samples_per_millisecond = ((@frequency * 16 * 2) / 8) / 1000 / @buffer.size.to_f

        @subsong = 0
      end

      def next_sample
        @buffers_generated += 1

        gme_play(@player, @buffer_size, @buffer)
        @buffer.read_array_of_short(@buffer_size).pack('s*')
      end

      def position
        @buffers_generated / @samples_per_millisecond
      end

      def complete?
        # TODO This should incorporate a fadeout of some kind,
        # as GME tracks end at a very rough point
        (gme_track_ended(@player) != 0) || position >= duration
      end

      def duration
        @info[:length]
      end

      def title
        @info[:song]
      end

      def composer
        @info[:author]
      end

      def comment
        @info[:comment]
      end

      def format
        @info[:system]
      end

      def channel_count
        gme_voice_count(@player)
      end

      def subsong; @subsong; end

      def subsong=(song)
        max = subsongs - 1
        if song > max
          raise Paula::SeekError, "subsong #{song} out of range (max: #{max})"
        end

        @subsong = song
        gme_start_track(@player, song)
      end

      def subsongs
        gme_track_count(@player)
      end
    end
  end
end
