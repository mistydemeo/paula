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
    return nil unless @extensions[format]

    @extensions[format].dup
  end

  def self.split_filename file
    suffix = File.extname(file)[1..-1].downcase
    prefix = File.basename(file, File.extname(file)).downcase

    [prefix, suffix]
  end
end
