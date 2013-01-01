require 'minitest/autorun'
require 'paula/core'

describe Paula do
  it "should be able to keep track of supported formats and libraries" do
    class Foo; end
    Paula.add_formats Foo, ['foo', 'bar']

    Paula.plays('foo').must_equal [Foo]
    Paula.plays('bar').must_equal [Foo]
  end

  it "should be able to construct a player object given a file and options" do
    player = Class.new(Paula::Player) { extensions 'mod' }
    Paula('file.mod', frequency: 44100).must_be_kind_of Paula::Player
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
