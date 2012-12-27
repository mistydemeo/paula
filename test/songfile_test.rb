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

  after do
    Paula.instance_variable_set :@players, []
    Paula.instance_variable_set :@extension_map, {}
    Paula.instance_variable_set :@preferred, []
    Paula.instance_variable_set :@preferred_map, {}
  end
end
