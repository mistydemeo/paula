require 'minitest/autorun'
require 'paula/songfile'
require 'paula/player'

describe Paula::SongFile do
  before do
    @file = Paula::SongFile.new('song.mod')

    @player = Class.new(Paula::Player) { extensions 'mod' }
    @preferred = Class.new(Paula::Player) { extensions 'mod' }
    Paula.prefer 'mod' => @preferred
  end

  it "should be able to correctly report the song's extension" do
    @file.suffix.must_equal 'mod'
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
    @file.to_s.must_equal 'song.mod'
  end

  it "should be able to return a Pathname representation of itself" do
    @file.to_pn.must_equal Pathname('song.mod')
  end

  it "should be able to create an appropriate player object based on file extension" do
    @file.find_player.ancestors.must_include Paula::Player
  end

  it "should be able to select an appropriate player given a player that autodetects formats" do
    autodetect_player = Class.new(Paula::Player) do
      detects_formats

      def self.can_play? file
        true if File.extname(file) == '.format'
      end
    end

    Paula::SongFile.new('file.format').find_player.must_be_same_as autodetect_player
  end

  it "should be able to select a preferred player for a given extension" do
    player1 = Class.new(Paula::Player) { extensions 'format' }
    player2 = Class.new(Paula::Player) { extensions 'format' }
    file = Paula::SongFile.new('file.format')

    file.find_player.must_be_same_as player1

    Paula.prefer 'format' => player2
    file.find_player.must_be_same_as player2
  end

  it "should be able to select a preferred player that autodetects formats" do
    player1 = Class.new(Paula::Player) do
      detects_formats
      def self.can_play? file
        File.extname(file) == '.format'
      end
    end
    player2 = Class.new(Paula::Player) do
      detects_formats
      def self.can_play? file
        File.extname(file) == '.format'
      end
    end
    file = Paula::SongFile.new('file.format')

    file.find_player.must_be_same_as player1

    Paula.prefer player2
    file.find_player.must_be_same_as player2
  end

  it "should select a preferred player by extension before a preferred autodetecting player" do
    player1 = Class.new(Paula::Player) do
      detects_formats
      def self.can_play? file
        File.extname(file) == '.format'
      end
    end
    player2 = Class.new(Paula::Player) { extensions 'format' }
    file = Paula::SongFile.new('file.format')

    Paula.prefer player1
    Paula.prefer 'format' => player2

    file.find_player.must_be_same_as player2
  end

  after do
    Paula.instance_variable_set :@players, []
    Paula.instance_variable_set :@extension_map, {}
    Paula.instance_variable_set :@preferred, []
    Paula.instance_variable_set :@preferred_map, {}
  end
end
