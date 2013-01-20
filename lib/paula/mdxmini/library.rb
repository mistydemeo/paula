require 'ffi'

module Paula
  module MDXMini
    extend FFI::Library
    ffi_lib "mdxmini"

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

    attach_function :mdx_set_rate, [ :int ], :void
    attach_function :mdx_set_dir, [ T_mdxmini, :string ], :void
    attach_function :mdx_open, [ T_mdxmini, :string, :string ], :int
    attach_function :mdx_disp_info, [ T_mdxmini ], :void
    attach_function :mdx_next_frame, [ T_mdxmini ], :int
    attach_function :mdx_frame_length, [ T_mdxmini ], :int
    attach_function :mdx_make_buffer, [ T_mdxmini, :short, :int ], :void
    attach_function :mdx_calc_sample, [ T_mdxmini, :pointer, :int ], :int
    attach_function :mdx_get_title, [ T_mdxmini, :pointer ], :void
    attach_function :mdx_get_length, [ T_mdxmini ], :int
    attach_function :mdx_set_max_loop, [ T_mdxmini, :int ], :void
    attach_function :mdx_stop, [ T_mdxmini ], :void
    attach_function :mdx_get_buffer_size, [ T_mdxmini ], :int
    attach_function :mdx_get_sample_size, [ T_mdxmini ], :int
    attach_function :mdx_get_tracks, [ T_mdxmini ], :int
    attach_function :mdx_get_current_notes, [ T_mdxmini, :pointer, :int ], :void
  end
end
