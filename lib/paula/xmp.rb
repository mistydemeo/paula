require 'paula/library'
require 'paula/player'

require 'ffi'

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

  class XmpInstrumentSub < FFI::Struct
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
           :ifr, :int,
           :hld, :int
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
           :vts, :int,
           :wts, :int,
           :map, [XmpInstrumentMap, 121],
           :sub, XmpInstrumentSub
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
           :xxp, XmpPattern,
           :xxt, XmpTrack,
           :xxi, XmpInstrument,
           :xxs, XmpSample,
           :xxc, [XmpChannel, 64],
           :xxo, [:uchar, 256]
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

  class XmpSequence < FFI::Struct
    layout(
           :entry_point, :int,
           :duration, :int
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
           :channel_info, [XmpModuleInfoChannelInfo, 64],
           :mod, XmpModule,
           :comment, :pointer,
           :sequence, :int,
           :num_sequences, :int,
           :seq_data, XmpSequence
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

  class Player < Paula::Player
    # TODO: add the full list of XMP's extensions
    extensions %w[mod xm]
    maximum_frequency 48000
    supports_title
    supports_comment
    supports_instruments

    def self.finalize ptr
      proc do
        XMP.xmp_player_end ptr
        XMP.xmp_release_module ptr
        XMP.xmp_free_context ptr
      end
    end

    def initialize file, opts
      super

      @context = XMP.xmp_create_context
      @info    = XMP::XmpModuleInfo.new

      if !XMP.xmp_load_module @context, file
        raise Paula::LoadError, "could not open file #{file}"
      end

      XMP.xmp_player_start @context, opts[:frequency], 0
      XMP.xmp_player_get_info @context, @info

      ObjectSpace.define_finalizer(self, self.class.finalize(@context))
    end

    def next_sample
      XMP.xmp_player_frame @context
      XMP.xmp_player_get_info @context, @info
      @info.buffer
    end

    # TODO: implement timeout
    def complete?
      @info[:loop_count] > @loops
    end

    def duration
      @info[:total_time]
    end
  end
end
