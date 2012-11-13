require 'paula/library'
require 'paula/mdxmini/player'

require 'ffi'

module Paula
  module MDXMini
    extend Paula::Library
    declare_library

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

    class T_mdxmini < FFI::ManagedStruct
      layout(
        :samples, :int,
        :channels, :int,
        :mdx, :pointer,
        :pdx, :pointer,
        :self, :pointer
      )
    end
  end
end
