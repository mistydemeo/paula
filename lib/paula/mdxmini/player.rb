require 'paula/player'

module Paula
  module MDXMini
    class Player < Paula::Player
      extensions 'mdx'
      supports_title
      supports_notes

      def initialize file, opts
        super

        MDXMini.mdx_set_rate @frequency
        @sample_size = 4096
        @buffer = FFI::MemoryPointer.new :char, @sample_size * 4, true
        @buffers_per_second = ((@frequency * 16 * 2) / 8) / @sample_size.to_f

        @mini = T_mdxmini.new
        MDXMini.mdx_open @mini, File.expand_path(file), File.dirname(file)
        MDXMini.mdx_set_max_loop @mini, @loops

        @duration = MDXMini.mdx_get_length @mini

        @buffers_generated = 0
      end

      def next_sample
        @buffers_generated += 1
        @finished = MDXMini.mdx_calc_sample @mini, @buffer, @sample_size

        @buffer.read_string(@buffer.size)
      end

      def title
        return @title if @title

        buffer = FFI::MemoryPointer.new :char, 100
        MDXMini.mdx_get_title @mini, buffer
        opts = {:replace => '?', :invalid => :replace, :undef => :replace}
        @title = buffer.read_string.force_encoding('Shift_JIS').encode!('utf-8', opts)
      end

      def complete?
        @finished == 0 || @buffers_generated > (duration * @buffers_per_second)
      end

      def duration
        @duration
      end
    end
  end
end
