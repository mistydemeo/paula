require 'paula/player'

require 'ffi'

module Paula
  module MDXMini
    extend FFI::Library
    ffi_lib "mdxmini"

    attach_function :mdx_open, [:pointer, :string, :string], :int
    attach_function :mdx_set_rate, [:int], :void
    attach_function :mdx_set_max_loop, [:pointer, :int], :void
    attach_function :mdx_disp_info, [:pointer], :void
    attach_function :mdx_next_frame, [:pointer], :int
    attach_function :mdx_frame_length, [:pointer], :int
    attach_function :mdx_make_buffer, [:short, :int], :void
    attach_function :mdx_calc_sample, [:pointer, :pointer, :int], :int
    attach_function :mdx_get_title, [:pointer, :pointer], :void
    attach_function :mdx_get_length, [:pointer], :int
    attach_function :mdx_get_tracks, [:pointer], :int
    attach_function :mdx_get_current_notes, [:pointer, :pointer, :int], :void
    attach_function :mdx_stop, [:pointer], :void
    attach_function :mdx_get_sample_size, [:pointer], :int
    attach_function :mdx_get_buffer_size, [:pointer], :int

    class T_mdxmini < FFI::Struct
      layout(
        :samples, :int,
        :channels, :int,
        :mdx, :pointer,
        :pdx, :pointer,
        :self, :pointer
      )
    end

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

        @buffers_generated = 0
      end

      def next_sample
        @buffers_generated += 1
        @finished = MDXMini.mdx_calc_sample @mini, @buffer, @sample_size

        @buffer.read_bytes(@buffer.size)
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
        MDXMini.mdx_get_length @mini
      end
    end
  end
end
