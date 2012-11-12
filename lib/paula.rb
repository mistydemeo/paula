require "paula/version"

module Paula
  def self.add_formats library, extensions
    @extensions ||= {}

    extensions.each do |ext|
      @extensions[ext] ||= []
      @extensions[ext] << library
    end
  end

  def self.plays format
    @extensions[format]
  end
end
