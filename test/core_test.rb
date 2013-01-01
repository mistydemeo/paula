require 'minitest/autorun'
require 'paula/core'

describe Paula do
  before do
    @player_klass
  end

  it "should be able to keep track of supported formats and libraries" do
    klass = Class.new
    Paula.add_formats klass, ['foo', 'bar']

    Paula.plays('foo').must_equal [klass]
    Paula.plays('bar').must_equal [klass]
  end

  it "should be able to track a player which autodetects formats" do
    klass = Class.new
    Paula.add_player klass
    Paula.autodetectors.must_include klass
  end

  it "should be able to prefer a player for a format" do
    klass = Class.new
    Paula.add_formats klass, ['foo', 'bar']
    Paula.prefer 'foo' => klass
    Paula.plays('foo', preferred: true).must_equal [klass]
  end

  it "should be able to prefer a player which autodetects formats" do
    klass = Class.new
    Paula.add_player klass
    Paula.prefer klass
    Paula.preferred_autodetectors.must_include klass
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
