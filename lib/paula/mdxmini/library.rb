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
    attach_function :mdx_make_buffer, [:pointer, :short, :int], :void
    attach_function :mdx_calc_sample, [:pointer, :pointer, :int], :int
    attach_function :mdx_get_title, [:pointer, :pointer], :void
    attach_function :mdx_get_length, [:pointer], :int
    attach_function :mdx_get_tracks, [:pointer], :int
    attach_function :mdx_get_current_notes, [:pointer, :pointer, :int], :void
    attach_function :mdx_stop, [:pointer], :void
    attach_function :mdx_get_sample_size, [:pointer], :int
    attach_function :mdx_get_buffer_size, [:pointer], :int

    class Songdata < FFI::Struct
      layout(
        :mdx2151, :pointer,
        :mdxmml_ym2151, :pointer,
        :pcm8, :pointer,
        :ym2151_c, :pointer
      )
    end

    class T_mdxmini < FFI::Struct
      layout(
        :samples, :int,
        :channels, :int,
        :mdx, :pointer,
        :pdx, :pointer,
        :self, :pointer,
        :songdata, Songdata.ptr
      )
    end
  end
end
