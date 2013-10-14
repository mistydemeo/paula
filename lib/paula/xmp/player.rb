require 'paula/xmp/library'
require 'paula/player'

module Paula
  module XMP
    class Player < Paula::Player
      extend Paula::XMP

      detects_formats
      maximum_frequency 48000
      supports_title
      supports_comment
      supports_instruments

      def self.finalize ptr
        proc do
          xmp_end_player(ptr)
          xmp_release_module(ptr)
          xmp_free_context(ptr)
        end
      end

      def self.can_play? file
        raise Paula::LoadError, "#{file} does not exist" unless file.exist?

        test_info = XmpTestInfo.new
        xmp_test_module(file, test_info) == 0 ? true : false
      end

      def initialize file, opts
        super
        extend Paula::XMP

        @context  = xmp_create_context()
        @songinfo = XmpModuleInfo.new
        @info     = XmpFrameInfo.new
        # XMP's loops aren't internal loops based around loop-points,
        # like other players; this literally means looping the entire
        # song beginning to end. Since it's inconsistent with other
        # players, just always set it to 0 (play once).
        @loops    = 0

        if !xmp_load_module(@context, file)
          raise Paula::LoadError, "could not open file #{file}"
        end

        xmp_start_player(@context, opts[:frequency], 0)
        xmp_get_frame_info(@context, @info)
        xmp_get_module_info(@context, @songinfo)

        ObjectSpace.define_finalizer(self, self.class.finalize(@context))
      end

      def next_sample
        xmp_play_frame(@context)
        xmp_get_frame_info(@context, @info)
        @info.buffer
      end

      # Returns nil if playback has not yet started.
      def sample_size
        @info[:buffer_size] == 0 ? nil : @info[:buffer_size]
      end

      def title
        return if @songinfo[:mod].null?

        @songinfo[:mod][:name].to_s
      end

      def comment
        return if @songinfo[:comment].null?

        @songinfo[:comment].to_s
      end

      # TODO: implement timeout
      def complete?
        @info[:loop_count] > @loops
      end

      def duration
        @info[:total_time]
      end

      def current_loop
        @info[:loop_count]
      end

      def position
        @info[:time]
      end

      def channel_count
        @info[:virt_channels]
      end

      def seek time
        if xmp_seek_time(@context, time) == 0
          true
        else
          # Need more detail here, but I'm not sure when this would fail
          raise Paula::SeekError, "seeking failed!"
        end
      end
    end
  end
end
