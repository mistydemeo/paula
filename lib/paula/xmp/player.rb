require 'paula/player'

module Paula
  module XMP
    class Player < Paula::Player
      detects_formats
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

      def self.can_play? file
        raise Paula::LoadError, "#{file} does not exist" unless File.exist? file

        test_info = XMP::XmpTestInfo.new
        XMP.xmp_test_module(file, test_info) == 0 ? true : false
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

      # Returns nil if playback has not yet started.
      def sample_size
        @info[:buffer_size] == 0 ? nil : @info[:buffer_size]
      end

      def title
        return nil if @info[:mod].null?

        @info[:mod][:name].to_s
      end

      def comment
        return nil if @info[:comment].null?

        @info[:comment].to_s
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

      def channels
        @info[:virt_channels]
      end
    end
  end
end
