require 'paula/player'

module Paula
  module MDXMini
    class Player < Paula::Player
      extend Paula::MDXMini

      extensions 'mdx'
      supports_title
      supports_notes

      def self.finalize ptr
        proc { mdx_stop(ptr) }
      end

      def initialize file, loops: 1, frequency: 44100
        super
        extend Paula::MDXMini

        mdx_set_rate(@frequency)
        @sample_size = 4096
        @buffer = FFI::MemoryPointer.new :char, @sample_size * 4, true
        @buffers_per_millisecond = ((@frequency * 16 * 2) / 8) / 1000 / @sample_size.to_f

        @mini = T_mdxmini.new
        mdx_open(@mini, @filename, @filename.dirname)
        mdx_set_max_loop(@mini, @loops)

        @duration = mdx_get_length(@mini)

        @buffers_generated = 0

        ObjectSpace.define_finalizer(self, self.class.finalize(@mini))
      end

      def next_sample
        @buffers_generated += 1
        @finished = mdx_calc_sample(@mini, @buffer, @sample_size)

        @buffer.read_string(@buffer.size)
      end

      def sample_size
        @sample_size
      end

      def title
        return @title if @title

        buffer = FFI::MemoryPointer.new :char, 100
        mdx_get_title(@mini, buffer)
        opts = {:replace => '?', :invalid => :replace, :undef => :replace}
        @title = buffer.read_string.force_encoding('Shift_JIS').encode!('utf-8', opts)
      end

      def format; 'MDX'; end

      def complete?
        @finished == 0 || position > duration
      end

      def duration
        @duration * 1000
      end

      def position
        @buffers_generated / @buffers_per_millisecond * 4
      end

      def channel_count
        mdx_get_tracks(@mini)
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
