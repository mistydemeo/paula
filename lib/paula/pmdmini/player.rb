require 'paula/player'

module Paula
  module PMDMini
    class Player < Paula::Player
      extensions 'm', 'm2', 'mz'
      supports_title
      supports_composer
      supports_notes

      def self.finalize
        proc { PMDMini.pmd_stop }
      end

      def initialize file, opts
        super

        PMDMini.pmd_init
        PMDMini.pmd_setrate @frequency

        @sample_size = 4096
        @buffer = FFI::MemoryPointer.new :char, @sample_size * 4, true
        @buffers_per_second = ((@frequency * 16 * 2) / 8) / @sample_size.to_f

        # Probably an upstream bug; pmdmini segfaults if pmd_is_pmd()
        # is not called on the file before pmd_play begins
        PMDMini.pmd_is_pmd file.to_s
        PMDMini.pmd_play file.to_s
        @duration = PMDMini.pmd_length_sec

        @buffers_generated = 0

        ObjectSpace.define_finalizer(self, self.class.finalize)
      end

      def next_sample
        @buffers_generated += 1
        @finished = PMDMini.pmd_renderer(@buffer, @sample_size)

        @buffer.read_string(@buffer.size)
      end

      def sample_size
        @sample_size
      end

      def title
        return @title if @title

        buffer = FFI::MemoryPointer.new :char, 100
        PMDMini.pmd_get_title buffer
        opts = {:replace => '?', :invalid => :replace, :undef => :replace}
        @title = buffer.read_string.force_encoding('Shift_JIS').encode!('utf-8', opts)
      end

      def composer
        return @composer if @composer

        buffer = FFI::MemoryPointer.new :char, 100
        PMDMini.pmd_get_compo buffer
        opts = {:replace => '?', :invalid => :replace, :undef => :replace}
        @composer = buffer.read_string.force_encoding('Shift_JIS').encode!('utf-8', opts)
      end

      def complete?
        @finished == 0 || @buffers_generated > (duration * @buffers_per_second)
      end

      def duration
        @duration
      end

      def channels
        PMDMini.pmd_get_tracks
      end
    end
  end
end
