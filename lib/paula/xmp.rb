require 'ffi'

module XMP
  extend FFI::Library
  ffi_lib 'xmp'

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

  class XmpModuleInfoChannelInfo < FFI::Struct
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
           :order, :int,
           :pattern, :int,
           :row, :int,
           :num_rows, :int,
           :frame, :int,
           :speed, :int,
           :bpm, :int,
           :time, :int,
           :frame_time, :int,
           :total_time, :int,
           :buffer, :pointer,
           :buffer_size, :int,
           :total_size, :int,
           :volume, :int,
           :loop_count, :int,
           :virt_channels, :int,
           :virt_used, :int,
           :vol_base, :int,
           :mod, :pointer,
           :comment, :pointer,
           :sequence, :int,
           :num_sequences, :int,
           :seq_data, :pointer,
           :channel_info, [XmpModuleInfoChannelInfo, 64]
    )

    def buffer
      self[:buffer].read_string self[:buffer_size]
    end
  end

  attach_function :xmp_create_context, [  ], :pointer
  attach_function :xmp_test_module, [ :pointer, :pointer ], :int
  attach_function :xmp_free_context, [ :pointer ], :void
  attach_function :xmp_load_module, [ :pointer, :string ], :int
  attach_function :xmp_release_module, [ :pointer ], :void
  attach_function :xmp_player_start, [ :pointer, :int, :int ], :int
  attach_function :xmp_player_frame, [ :pointer ], :int
  attach_function :xmp_player_get_info, [ :pointer, :pointer ], :void
  attach_function :xmp_player_end, [ :pointer ], :void
  attach_function :xmp_inject_event, [ :pointer, :int, :pointer ], :void
  attach_function :xmp_get_format_list, [  ], :string
  attach_function :xmp_control, [ :pointer, :int, :varargs ], :int
end
