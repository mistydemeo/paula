require 'minitest/autorun'
require 'paula/core'

describe Paula do
  it "should be able to keep track of supported formats and libraries" do
    class Foo; end
    Paula.add_formats Foo, ['foo', 'bar']

    Paula.plays('foo').must_equal [Foo]
    Paula.plays('bar').must_equal [Foo]
  end

  it "should be able to split a filename into prefix and suffix" do
    file = "song.mod"
    prefix, suffix = Paula.split_filename file
    prefix.must_equal "song"
    suffix.must_equal "mod"
  end

  it "should be able to create an appropriate player object based on file extension" do
    file = "song.mod"

    klass = Class.new(Paula::Player) { extensions 'mod' }

    Paula(file, frequency: 44100).must_be_kind_of Paula::Player
  end

  it "should be able to create an appropriate player object given a player that autodetects formats" do
    autodetect_player = Class.new(Paula::Player) do
      detects_format

      def self.can_play? file
        true if File.extname(file) == '.format'
      end
    end

    Paula('file.format', frequency: 44100).must_be_instance_of autodetect_player
  end

  it "should be able to prefer a particular player for a given extension" do
    player1 = Class.new(Paula::Player) { extensions 'format' }
    player2 = Class.new(Paula::Player) { extensions 'format' }

    Paula('file.format', frequency: 44100).must_be_instance_of player1

    Paula.prefer 'format' => player2
    Paula('file.format', frequency: 44100).must_be_instance_of player2
  end

  it "should be able to prefer a player that autodetects formats" do
    player1 = Class.new(Paula::Player) do
      detects_format
      def self.can_play? file
        File.extname(file) == '.format'
      end
    end
    player2 = Class.new(Paula::Player) do
      detects_format
      def self.can_play? file
        File.extname(file) == '.format'
      end
    end

    Paula('file.format', frequency: 44100).must_be_instance_of player1

    Paula.prefer player2
    Paula('file.format', frequency: 44100).must_be_instance_of player2
  end

  it "should select a preferred player by extension before a preferred autodetecting player" do
    player1 = Class.new(Paula::Player) do
      detects_format
      def self.can_play? file
        File.extname(file) == '.format'
      end
    end
    player2 = Class.new(Paula::Player) { extensions 'format' }

    Paula.prefer player1
    Paula.prefer 'format' => player2

    Paula('file.format', frequency: 44100).must_be_instance_of player2
  end

  it "should raise if a player object is requested for an unrecognized filetype" do
    lambda {Paula('file.foo', frequency: 44100)}.must_raise Paula::LoadError
  end

  it "should raise if no player could be found for the provided file" do
    klass = Class.new(Paula::Player) do
      extensions 'fail'
      def initialize(*args); raise Paula::LoadError; end
    end

    lambda {Paula('file.fail', frequency: 44100)}.must_raise Paula::LoadError
  end

  after do
    Paula.instance_variable_set :@players, []
    Paula.instance_variable_set :@extension_map, {}
    Paula.instance_variable_set :@preferred, []
    Paula.instance_variable_set :@preferred_map, {}
  end
end
