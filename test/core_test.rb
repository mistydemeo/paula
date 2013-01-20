require 'minitest/autorun'
require 'paula/core'

describe Paula do
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
end
