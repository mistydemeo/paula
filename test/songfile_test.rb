require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'

require 'paula/registry'
require 'paula/songfile'
require 'paula/player'

describe Paula::SongFile do
  before do
    @tmpdir = Dir.mktmpdir
    Dir.chdir @tmpdir

    @registry = Paula::Registry.new
    @file = Paula::SongFile.new('song.mod')
    @file.registry = @registry
    FileUtils.touch @file

    r = @registry
    @player = Class.new(Paula::Player) do
      register_to r
      extensions 'mod'
    end
    @preferred = Class.new(Paula::Player) do
      register_to r
      extensions 'mod'
    end
    @registry.prefer 'mod' => @preferred
  end

  it "should be able to correctly report the song's extension" do
    @file.suffix.must_equal 'mod'
  end

  it "should return an empty string for the extname of a file with no extension" do
    Paula::SongFile.new('foo').suffix.must_equal ""
  end

  it "should be able to correctly report the song's prefix" do
    @file.prefix.must_equal 'song'
  end

  it "should be able to report which players it can be played by" do
    @file.played_by(preferred: false).must_equal [@player, @preferred]
  end

  it "should also be able to report preferred players that can play it" do
    @file.played_by(preferred: true).must_equal [@preferred]
  end

  it "should be able to return a string representation of itself" do
    @file.to_s.must_equal File.realpath(File.join(@tmpdir, 'song.mod'))
  end

  # This ensures that it can be used as an argument to methods that
  # expect strings
  it "should be implicitly convertable to a string" do
    String.try_convert(@file).wont_be_nil
  end

  it "should be able to return a Pathname representation of itself" do
    @file.to_pn.must_equal Pathname('song.mod').expand_path
  end

  it "should be able to report its size" do
    @file.size.must_equal 0
  end

  it "should be able to report if it exists" do
    assert @file.exist?
    refute Paula::SongFile.new('foo').exist?
  end

  it "should be able to return a string representation of its directory" do
    @file.dirname.must_equal File.realpath(@tmpdir)
  end

  it "should be able to create an appropriate player object based on file extension" do
    @file.find_player.ancestors.must_include Paula::Player
  end

  it "should be able to select an appropriate player given a player that autodetects formats" do
    r = Paula::Registry.new
    autodetect_player = Class.new(Paula::Player) do
      register_to r
      detects_formats

      def self.can_play? file
        true if File.extname(file) == '.format'
      end
    end

    file = Paula::SongFile.new('file.format')
    file.registry = r
    file.find_player.must_be_same_as autodetect_player
  end

  it "should be able to select a preferred player for a given extension" do
    r = @registry
    player1 = Class.new(Paula::Player) do
      register_to r
      extensions 'format'
    end
    player2 = Class.new(Paula::Player) do
      register_to r
      extensions 'format'
    end
    file = Paula::SongFile.new('file.format')
    file.registry = @registry

    file.find_player.must_be_same_as player1

    @registry.prefer 'format' => player2
    file.find_player.must_be_same_as player2
  end

  it "should be able to select a preferred player that autodetects formats" do
    r = @registry
    player1 = Class.new(Paula::Player) do
      register_to r
      detects_formats
      def self.can_play? file
        File.extname(file) == '.format'
      end
    end
    player2 = Class.new(Paula::Player) do
      register_to r
      detects_formats
      def self.can_play? file
        File.extname(file) == '.format'
      end
    end
    file = Paula::SongFile.new('file.format')
    file.registry = @registry

    file.find_player.must_be_same_as player1

    @registry.prefer player2
    file.find_player.must_be_same_as player2
  end

  it "should select a preferred player by extension before a preferred autodetecting player" do
    r = @registry
    player1 = Class.new(Paula::Player) do
      register_to r
      detects_formats
      def self.can_play? file
        File.extname(file) == '.format'
      end
    end
    player2 = Class.new(Paula::Player) do
      register_to r
      extensions 'format'
    end
    file = Paula::SongFile.new('file.format')
    file.registry = @registry

    @registry.prefer player1
    @registry.prefer 'format' => player2

    file.find_player.must_be_same_as player2
  end

  it "should default to looking up players in Paula::CentralRegistry" do
    Paula::SongFile.new('foo').registry.must_equal Paula::CentralRegistry
  end

  it "should be able to be constructed from another SongFile" do
    sf = Paula::SongFile.new('foo/bar')
    sf = Paula::SongFile.new(sf)
    sf.prefix.must_equal('bar')
  end

  after do
    FileUtils.remove_entry_secure @tmpdir
  end
end
