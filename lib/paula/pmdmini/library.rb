require 'ffi'

module Paula
  module PMDMini
    extend FFI::Library
    ffi_lib "pmdmini"

    attach_function :pmd_init, [  ], :void
    attach_function :pmd_setrate, [ :int ], :void
    attach_function :pmd_is_pmd, [ :string ], :int
    attach_function :pmd_play, [ :string ], :int
    attach_function :pmd_length_sec, [  ], :int
    attach_function :pmd_loop_sec, [  ], :int
    attach_function :pmd_renderer, [ :pointer, :int ], :void
    attach_function :pmd_stop, [  ], :void
    attach_function :pmd_get_title, [ :pointer ], :void
    attach_function :pmd_get_compo, [ :pointer ], :void
    attach_function :pmd_get_tracks, [  ], :int
    attach_function :pmd_get_current_notes, [ :pointer, :int ], :void
  end
end
