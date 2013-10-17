require 'paula/player'

module Paula
  module GME
    class Player < Paula::Player
      extend Paula::GME

      extensions 'spc'
      supports_title

      def initialize file, opts
        super
        extend Paula::GME

        @player = FFI::MemoryPointer.new(:pointer)
        gme_open_file(file, @player.get_pointer(0), @frequency)
        gme_start_track(@player, 0)

        @buffer_size = 4096
        @buffer = FFI::MemoryPointer.new :short, @buffer_size
      end

      def next_sample
        gme_play(@pointer, @buffer_size, @buffer)
        @buffer.read_bytes(@buffer_size)
      end

      def complete?
        gme_track_ended(@player)
      end
    end
  end
end