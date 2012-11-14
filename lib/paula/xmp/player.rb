require 'paula/player'

module Paula
  module XMP
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

      # Returns 0 if playback has not yet started.
      def sample_size
        @info[:buffer_size]
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
    end
  end
end
