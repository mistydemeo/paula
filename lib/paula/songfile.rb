require 'pathname'

module Paula
  class SongFile
    def initialize file
      return file if file.is_a? Paula::SongFile
      @file = Pathname(file)
    end

    def prefix
      @file.basename(@file.extname).to_s.downcase
    end

    def suffix
      @file.extname[1..-1].downcase
    end

    def played_by opts={preferred: false}
      Paula.plays(suffix, opts) || Paula.plays(prefix, opts)
    end

    def to_s; @file.to_s; end
    def to_str; @file.to_s; end
    def to_pn; @file; end
  end
end
