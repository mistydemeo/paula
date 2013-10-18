require 'paula/player'

module Paula
  module GME
    class Player < Paula::Player
      extend Paula::GME

      extensions *%w[vgm gym spc sap nsfe nsf ay gbs hes kss]
      supports_title

      def initialize file, opts
        super
        extend Paula::GME

        ptr = FFI::MemoryPointer.new(:pointer)
        gme_open_file(file, ptr, @frequency)
        @player = ptr.read_pointer
        gme_start_track(@player, 0)

        @buffer_size = 4096
        @buffer = FFI::MemoryPointer.new :short, @buffer_size
      end

      def next_sample
        gme_play(@player, @buffer_size, @buffer)
        @buffer.read_array_of_short(@buffer_size).pack('s*')
      end

      def complete?
        gme_track_ended(@player) != 0
      end
    end
  end
end