require 'ffi'

module Paula
  module GME
    extend FFI::Library
    ffi_lib 'gme'

    typedef :string, :gme_err_t

    # Basic operations
    attach_function :gme_open_file, [ :string, :pointer, :int ], :gme_err_t
    attach_function :gme_track_count, [ :pointer ], :int
    attach_function :gme_start_track, [ :pointer, :int ], :gme_err_t
    attach_function :gme_play, [ :pointer, :int, :pointer ], :gme_err_t
    attach_function :gme_delete, [ :pointer ], :void

    # Track position/length
    attach_function :gme_set_fade, [ :pointer, :int ], :void
    attach_function :gme_track_ended, [ :pointer ], :int
    attach_function :gme_tell, [ :pointer ], :int
    attach_function :gme_seek, [ :pointer, :int ], :gme_err_t

    GME_INFO_ONLY = -1

    class GmeInfoT < FFI::Struct
      layout :length, :int,
             :intro_length, :int,
             :loop_length, :int,
             :play_length, :int,
             # i4 - i15 are reserved
             :i4, :int,
             :i5, :int,
             :i6, :int,
             :i7, :int,
             :i8, :int,
             :i9, :int,
             :i10, :int,
             :i11, :int,
             :i12, :int,
             :i13, :int,
             :i14, :int,
             :i15, :int,
             :system, :pointer,
             :game, :pointer,
             :song, :pointer,
             :author, :pointer,
             :copyright, :pointer,
             :comment, :pointer,
             :dumper, :pointer,
             # These are reserved too
             :s7, :pointer,
             :s8, :pointer,
             :s9, :pointer,
             :s10, :pointer,
             :s11, :pointer,
             :s12, :pointer,
             :s13, :pointer,
             :s14, :pointer,
             :s15, :pointer
    end

    # Informational
    attach_function :gme_warning, [ :pointer ], :string
    attach_function :gme_load_m3u, [ :pointer, :string ], :gme_err_t
    attach_function :gme_clear_playlist, [ :pointer ], :void
    attach_function :gme_track_info, [ :pointer, GmeInfoT, :int ], :gme_err_t
    attach_function :gme_free_info, [ GmeInfoT ], :void

    # Advanced playback
    attach_function :gme_set_stereo_depth, [ :pointer, :double ], :void
    attach_function :gme_ignore_silence, [ :pointer, :int ], :void
    attach_function :gme_set_tempo, [ :pointer, :double ], :void
    attach_function :gme_voice_count, [ :pointer ], :int
    attach_function :gme_voice_name, [ :pointer, :int ], :string
    attach_function :gme_mute_voice, [ :pointer, :int, :int ], :void
    attach_function :gme_mute_voices, [ :pointer, :int ], :void

    class GmeEqualizerT < FFI::Struct
      layout :treble, :double,
             :bass, :double,
             :d2, :double,
             :d3, :double,
             :d4, :double,
             :d5, :double,
             :d6, :double,
             :d7, :double,
             :d8, :double,
             :d9, :double
    end

    attach_function :gme_equalizer, [ :pointer, GmeEqualizerT ], :void
    attach_function :gme_set_equalizer, [ :pointer, GmeEqualizerT ], :void
    attach_function :gme_enable_accuracy, [ :pointer, :int ], :void

    # Game music types
    attach_function :gme_type_list, [ ], :pointer
    attach_function :gme_type_system, [ :pointer ], :string
    attach_function :gme_type_multitrack, [ :pointer ], :int

    # Advanced file loading
    attach_function :gme_open_data, [ :pointer, :long, :pointer, :int ], :gme_err_t
    attach_function :gme_identify_header, [ :string ], :string
    attach_function :gme_identify_extension, [ :string ], :string
    attach_function :gme_identify_file, [ :string, :pointer ], :gme_err_t
    attach_function :gme_new_emu, [ :pointer, :int ], :pointer
    attach_function :gme_load_file, [ :pointer, :string ], :gme_err_t
    attach_function :gme_load_data, [ :pointer, :pointer, :long ], :gme_err_t
    attach_function :gme_load_m3u_data, [ :pointer, :pointer, :long ], :gme_err_t

    # User data
    attach_function :gme_set_user_data, [ :pointer, :pointer ], :void
    attach_function :gme_user_data, [ :pointer ], :pointer
  end
end