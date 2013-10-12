require 'ffi'

module Paula
  module XMP
    extend FFI::Library
    ffi_lib 'xmp'

    class XmpChannel < FFI::Struct
      layout(
             :pan, :int,
             :vol, :int,
             :flg, :int
      )
    end

    class XmpPattern < FFI::Struct
      layout(
             :rows, :int,
             :index, [:int, 1]
      )
    end

    class XmpEvent < FFI::Struct
      layout(
             :note, :uchar,
             :ins, :uchar,
             :vol, :uchar,
             :fxt, :uchar,
             :fxp, :uchar,
             :f2t, :uchar,
             :f2p, :uchar,
             :_flag, :uchar
      )
    end

    class XmpTrack < FFI::Struct
      layout(
             :rows, :int,
             :event, [XmpEvent, 1]
      )
    end

    class XmpEnvelope < FFI::Struct
      layout(
             :flg, :int,
             :npt, :int,
             :scl, :int,
             :sus, :int,
             :sue, :int,
             :lps, :int,
             :lpe, :int,
             :data, [:short, 32*2]
      )
    end

    class XmpInstrumentMap < FFI::Struct
      layout(
             :ins, :uchar,
             :xpo, :char
      )
    end

    class XmpSubinstrument < FFI::Struct
      layout(
             :vol, :int,
             :gvl, :int,
             :pan, :int,
             :xpo, :int,
             :fin, :int,
             :vwf, :int,
             :vde, :int,
             :vra, :int,
             :vsw, :int,
             :rvv, :int,
             :sid, :int,
             :nna, :int,
             :dct, :int,
             :dca, :int,
             :ifc, :int,
             :ifr, :int
      )
    end

    class XmpInstrument < FFI::Struct
      layout(
             :name, [:char, 32],
             :vol, :int,
             :nsm, :int,
             :rls, :int,
             :aei, XmpEnvelope,
             :pei, XmpEnvelope,
             :fei, XmpEnvelope,
             :map, [XmpInstrumentMap, 121],
             :sub, XmpSubinstrument.ptr,
             :extra, :pointer
      )
    end

    class XmpSample < FFI::Struct
      layout(
             :name, [:char, 32],
             :len, :int,
             :lps, :int,
             :lpe, :int,
             :flg, :int,
             :data, :pointer
      )
    end

    class XmpSequence < FFI::Struct
      layout(
             :entry_point, :int,
             :duration, :int
      )
    end

    class XmpModule < FFI::Struct
      layout(
             :name, [:char, 64],
             :type, [:char, 64],
             :pat, :int,
             :trk, :int,
             :chn, :int,
             :ins, :int,
             :smp, :int,
             :spd, :int,
             :bpm, :int,
             :len, :int,
             :rst, :int,
             :gvl, :int,
             :xxp, XmpPattern.ptr,
             :xxt, XmpTrack.ptr,
             :xxi, XmpInstrument.ptr,
             :xxs, XmpSample.ptr,
             :xxc, [XmpChannel, 64],
             :xxo, [:uchar, 256]
      )
    end

    class XmpTestInfo < FFI::Struct
      layout(
             :name, [:char, 64],
             :type, [:char, 64]
      )
    end

    class XmpChannelInfo < FFI::Struct
      layout(
             :period, :uint,
             :position, :uint,
             :pitchbend, :short,
             :note, :uchar,
             :instrument, :uchar,
             :sample, :uchar,
             :volume, :uchar,
             :pan, :uchar,
             :reserved, :uchar,
             :event, XmpEvent
      )
    end

    class XmpModuleInfo < FFI::Struct
      layout(
             :md5, [:uchar, 16],
             :vol_base, :int,
             :mod, XmpModule.ptr,
             :comment, :pointer,
             :num_sequences, :int,
             :seq_data, XmpSequence.ptr
      )
    end

    class XmpFrameInfo < FFI::Struct
      layout(
             :pos, :int,
             :pattern, :int,
             :row, :int,
             :num_rows, :int,
             :frame, :int,
             :speed, :int,
             :bpm, :int,
             :time, :int,
             :total_time, :int,
             :frame_time, :int,
             :buffer, :pointer,
             :buffer_size, :int,
             :total_size, :int,
             :volume, :int,
             :loop_count, :int,
             :virt_channels, :int,
             :virt_used, :int,
             :sequence, :int,
             :channel_info, [XmpChannelInfo, 64],
      )

      def buffer
        self[:buffer].read_string self[:buffer_size]
      end
    end

    # Most of XMP's player-based functions are based around its
    # xmp_context type, which is a typedef for char*
    typedef :pointer, :xmp_context

    attach_function :xmp_create_context, [  ], :xmp_context
    attach_function :xmp_free_context, [ :xmp_context ], :void
    attach_function :xmp_test_module, [ :string, XmpTestInfo ], :int
    attach_function :xmp_load_module, [ :xmp_context, :string ], :int
    attach_function :xmp_release_module, [ :xmp_context ], :void
    attach_function :xmp_start_player, [ :xmp_context, :int, :int ], :int
    attach_function :xmp_play_frame, [ :xmp_context ], :int
    attach_function :xmp_get_frame_info, [ :xmp_context, XmpFrameInfo ], :void
    attach_function :xmp_end_player, [ :xmp_context ], :void
    attach_function :xmp_inject_event, [ :xmp_context, :int, :pointer ], :void
    attach_function :xmp_get_module_info, [ :xmp_context, XmpModuleInfo ], :void
    attach_function :xmp_get_format_list, [  ], :string
    attach_function :xmp_next_position, [ :xmp_context ], :int
    attach_function :xmp_prev_position, [ :xmp_context ], :int
    attach_function :xmp_set_position, [ :xmp_context, :int ], :int
    attach_function :xmp_stop_module, [ :xmp_context ], :void
    attach_function :xmp_restart_module, [ :xmp_context ], :void
    attach_function :xmp_seek_time, [ :xmp_context, :int ], :int
    attach_function :xmp_channel_mute, [ :xmp_context, :int, :int ], :int
    attach_function :xmp_channel_vol, [ :xmp_context, :int, :int ], :int
  end
end
