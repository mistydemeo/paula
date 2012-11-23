require 'minitest/autorun'
require 'paula/core'

describe Paula do
  it "should be able to keep track of supported formats and libraries" do
    class Foo; end
    Paula.add_formats Foo, ['foo', 'bar']

    Paula.plays('foo').must_equal [Foo]
    Paula.plays('bar').must_equal [Foo]

    Paula.instance_variable_set :@extensions, {}
  end

  it "should be able to split a filename into prefix and suffix" do
    file = "song.mod"
    prefix, suffix = Paula.split_filename file
    prefix.must_equal "song"
    suffix.must_equal "mod"
  end

  it "should be able to create an appropriate player object" do
    file = "song.mod"

    klass = Class.new(Paula::Player) { extensions 'mod' }

    Paula(file, frequency: 44100).must_be_kind_of Paula::Player
    Paula.instance_variable_set :@extensions, {}
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
    Paula.instance_variable_set :@extensions, {}
  end
end
