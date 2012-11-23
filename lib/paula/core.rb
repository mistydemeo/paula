def Paula(file, opts)
  prefix, suffix = Paula.split_filename file
  players = Paula.plays(suffix) || Paula.plays(prefix)

  # it's a reasonable guess that the significant part is a regular
  # file extension, not an Amiga-style prefix
  raise Paula::LoadError, "unrecognized filetype: #{suffix}" if players.nil?

  begin
    return players.shift.new(file, opts)
  rescue Paula::LoadError
  end while !players.empty?

  raise Paula::LoadError, "no appropriate player found for #{file}"
end

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