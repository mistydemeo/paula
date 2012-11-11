require 'paula/exceptions'

module Paula
  class Library
    class << self
      def maximum_frequency freq=nil
        @maximum_frequency || @maximum_frequency = freq
      end

      def extensions ext=nil
        ext = [ext] unless ext.is_a? Array
        @extensions || @extensions = ext
      end

      def can_play? file
        extension = File.extname(file)[1..-1]
        prefix = File.basename(file, File.extname(file))
        extensions.include?(extension) || extensions.include?(prefix)
      end
    end

    def initialize opts
      # until rescaling is implemented
      if opts[:frequency] > self.class.maximum_frequency
        raise Paula::InvalidFrequencyError, "#{opts[:frequency]} is greater than the maximum supported frequency of #{self.class.maximum_frequency}"
      end
    end
  end
end
