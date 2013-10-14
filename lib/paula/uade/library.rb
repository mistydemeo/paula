require 'ffi'

require 'paula/system_constants/path_max'

module Paula
  module UADE
    extend FFI::Library
    ffi_lib 'uade'

    UADE_CHANNELS = 2
    UADE_BYTES_PER_SAMPLE = 2
    UADE_BYTES_PER_FRAME = UADE_CHANNELS * UADE_BYTES_PER_SAMPLE

    class UadeFile < FFI::Struct
      layout :name, :char,
             :data, :char,
             :size, :size_t
    end

    class UadeSubsongInfo < FFI::Struct
      layout :cur, :int,
             :min, :int,
             :def, :int,
             :max, :int
    end

    UADE_MAX_EXT_LEN = 16

    class UadeDetectionInfo < FFI::Struct
      layout :custom, :int,
             :content, :int,
             :ext, [:char, UADE_MAX_EXT_LEN],
             :ep, :pointer
    end

    class UadeSongInfo < FFI::Struct
      layout :subsongs, UadeSubsongInfo,
             :detectioninfo, UadeDetectionInfo,
             :modulebytes, :size_t,
             :modulemd5, [:char, 33],
             :duration, :double,
             :subsongbytes, :int64_t,
             :songbytes, :int64_t,
             :modulefname, [:char, Paula::SystemConstants::PATH_MAX],
             :playerfname, [:char, Paula::SystemConstants::PATH_MAX],
             :formatname, [:char, 256],
             :modulename, [:char, 256],
             :playername, [:char, 256]
    end

    enum :uade_song_info_type, [
      :module_info, 0,
      :hex_dump_info,
      :number_of_infos
    ]

    RMC_MAGIC = "rmc\x00\xfb\x13\xf6\x1f\xa2"
    RMC_MAGIC_LEN = 9

    enum :uade_seek_mode, [
      :not_seeking, 0,
      :song_relative,
      :subsong_relative,
      :position_relative
    ]

    enum :uade_option, [
      :uc_no_option, 0x1000,
      :base_dir,
      :content_detection,
      :disable_timeouts,
      :enable_timeouts,
      :eagleplayer_option,
      :filter_type,
      :force_led_off,
      :force_led_on,
      :force_led,
      :frequency,
      :gain,
      :headphones,
      :headphones2,
      :ignore_player_check,
      :no_filter,
      :no_headphones,
      :no_panning,
      :no_postprocessing,
      :no_ep_end,
      :ntsc,
      :one_subsong,
      :pal,
      :panning_value,
      :player_file,
      :resampler,
      :score_file,
      :silence_timeout_value,
      :speed_hack,
      :subsong_timeout_value,
      :timeout_value,
      :uadecore_file,
      :uae_config_file,
      :use_text_scope,
      :verbose
    ]

    enum :uade_effect_t, [
      :allow, 1,
      :gain,
      :headphones,
      :headphones2,
      :pan
    ]

    enum :uade_notification_type, [
      :message, 1,
      :song_end
    ]

    class UadeNotificationSongEnd < FFI::Struct
      layout :happy, :int,
             :stopnow, :int,
             :subsong, :int,
             :subsongbytes, :int64_t,
             :reason, :char
    end

    class UadeNotificationUnion < FFI::Struct
      layout :msg, :char,
             :song_end, UadeNotificationSongEnd
    end

    class UadeNotification < FFI::Struct
      layout :type, :uade_notification_type,
             :union, UadeNotificationUnion
    end

    attach_function :uade_cleanup_state, [ :pointer ], :void

    # Configuration functions; these first few take uade_config structs
    # as their pointers, such as the one returned from uade_get_effective_config
    attach_function :uade_config_set_defaults, [ :pointer ], :void
    attach_function :uade_config_set_option, 
                      [ :pointer, :uade_option, :string ], :void
    attach_function :uade_config_toggle_boolean,
                      [ :pointer, :uade_option ], :int
    # These next few configuration functions are based on the song state,
    # and their pointer is to a uade_state instead
    attach_function :uade_effect_disable,
                      [ :pointer, :uade_effect_t ], :void
    attach_function :uade_effect_enable,
                      [ :pointer, :uade_effect_t ], :void
    attach_function :uade_effect_is_enabled,
                      [ :pointer, :uade_effect_t ], :int
    attach_function :uade_effect_toggle,
                      [ :pointer, :uade_effect_t ], :void
    attach_function :uade_effect_gain_set_amount,
                      [ :pointer, :float ], :void
    attach_function :uade_effect_pan_set_amount,
                      [ :pointer, :float ], :void
    # Takes a uade_event
    attach_function :uade_event_name, [ :pointer ], :char
    # Returns an opaque uade_config struct pointer,
    # given a uade_state pointer.
    attach_function :uade_get_effective_config,
                      [ :pointer ], :pointer

    # First argument is a uade_event, second is a uade_state
    attach_function :uade_get_event, [ :pointer, :pointer ], :int
    attach_function :uade_get_filter_state, [ :pointer ], :int

    attach_function :uade_read, [ :pointer, :size_t, :pointer ], :ssize_t

    attach_function :uade_read_notification,
                      [ UadeNotification, :pointer ], :int
    attach_function :uade_cleanup_notification, [ UadeNotification ], :void

    # The following functions get song information and take
    # a pointer to a uade_state
    attach_function :uade_get_sampling_rate, [ :pointer ], :int
    # Returns a uade_song_info
    attach_function :uade_get_song_info, [ :pointer ], UadeSongInfo
    attach_function :uade_is_our_file, [ :string, :pointer ], :int
    attach_function :uade_is_our_file_from_buffer,
                      [ :string, :pointer, :size_t, :pointer ], :int
    attach_function :uade_is_rmc, [ :string, :size_t ], :int
    attach_function :uade_is_rmc_file, [ :string ], :int
    attach_function :uade_is_verbose, [ :pointer ], :int
    attach_function :uade_get_rmc_from_state, [ :pointer ], :pointer

    attach_function :uade_new_state, [ :pointer ], :pointer
    attach_function :uade_load_amiga_file,
                      [ :string, :string, :pointer ], :pointer

    attach_function :uade_next_subsong, [ :pointer ], :int
    attach_function :uade_play, [ :string, :int, :pointer ], :int
    attach_function :uade_play_from_buffer,
                      [ :string, :pointer, :size_t, :int, :pointer ], :int

    attach_function :uade_set_filter_state, [ :pointer, :int ], :int

    attach_function :uade_set_amiga_loader,
                      [ :pointer, :pointer, :pointer ], :void

    attach_function :uade_set_debug, [ :pointer ], :void
    attach_function :uade_set_song_options,
                      [ :pointer, :string, :pointer ], :int

    attach_function :uade_seek,
                      [ :uade_seek_mode, :double, :int, :pointer ], :int
    attach_function :uade_seek_samples,
                      [ :uade_seek_mode, :ssize_t, :int, :pointer ], :int
    attach_function :uade_is_seeking, [ :pointer ], :int
    attach_function :uade_get_time_position,
                      [ :uade_seek_mode, :pointer ], :double
    attach_function :uade_song_info,
                      [ :string, :size_t, :string, :uade_song_info_type], :int

    attach_function :uade_stop, [ :pointer ], :int

    attach_function :uade_rmc_get_file, [ :pointer, :string ], :pointer
    attach_function :uade_rmc_get_module, [ :pointer, :pointer ], :int
    attach_function :uade_rmc_get_meta, [ :pointer ], :pointer
    attach_function :uade_rmc_get_subsongs, [ :pointer ], :pointer
    attach_function :uade_rmc_get_song_length, [ :pointer ], :double
    attach_function :uade_rmc_decode, [ :pointer, :size_t ], :pointer
    attach_function :uade_rmc_decode_file, [ :string ], :pointer
    attach_function :uade_rmc_record_file,
                      [ :pointer, :string, :pointer, :size_t ], :int

    attach_function :uade_atomic_fread, [ :pointer, :size_t, :size_t, :pointer ], :size_t
    attach_function :uade_file, [ :string, :pointer, :size_t ], :pointer
    attach_function :uade_file_free, [ :pointer ], :void
    attach_function :uade_file_load, [ :pointer ], :pointer
    attach_function :uade_read_file, [ :size_t, :string ], :void
  end
end
