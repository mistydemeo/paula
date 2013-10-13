require 'paula/player'

module Paula
  module PMDMini
    class Player < Paula::Player
      extend Paula::PMDMini

      extensions 'm', 'm2', 'mz'
      supports_title
      supports_composer
      supports_notes

      def self.finalize
        proc { pmd_stop() }
      end

      def initialize file, opts
        super
        include Paula::PMDMini

        pmd_init()
        pmd_setrate(@frequency)

        @sample_size = 4096
        @buffer = FFI::MemoryPointer.new :char, @sample_size * 4, true
        @buffers_per_millisecond = ((@frequency * 16 * 2) / 8) / 1000 / @sample_size.to_f

        # Probably an upstream bug; pmdmini segfaults if pmd_is_pmd()
        # is not called on the file before pmd_play begins
        pmd_is_pmd(@filename)
        pmd_play(@filename)
        @duration = pmd_length_sec()

        @buffers_generated = 0

        ObjectSpace.define_finalizer(self, self.class.finalize)
      end

      def next_sample
        @buffers_generated += 1
        @finished = pmd_renderer(@buffer, @sample_size)

        @buffer.read_string(@buffer.size)
      end

      def sample_size
        @sample_size
      end

      def title
        return @title if @title

        buffer = FFI::MemoryPointer.new :char, 100
        pmd_get_title(buffer)
        opts = {:replace => '?', :invalid => :replace, :undef => :replace}
        @title = buffer.read_string.force_encoding('Shift_JIS').encode!('utf-8', opts)
      end

      def composer
        return @composer if @composer

        buffer = FFI::MemoryPointer.new :char, 100
        pmd_get_compo(buffer)
        opts = {:replace => '?', :invalid => :replace, :undef => :replace}
        @composer = buffer.read_string.force_encoding('Shift_JIS').encode!('utf-8', opts)
      end

      def complete?
        @finished == 0 || @buffers_generated > (duration * @buffers_per_millisecond)
      end

      def duration
        @duration * 1000
      end

      def channels
        pmd_get_tracks()
      end

      def seek time
        # No backwards seeking
        return if 0 > time
        (time * @buffers_per_millisecond).to_i.times {next_sample}

        true
      end
    end
  end
end
