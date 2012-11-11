require 'minitest/autorun'
require 'paula/library'

describe Paula::Library do
  it "should be able to define the maximum frequency" do
    klass = Class.new(Paula::Library) do
      maximum_frequency 44100
    end

    klass.maximum_frequency.must_equal 44100
  end

  it "should raise when an unsupported frequency is requested" do
    klass = Class.new(Paula::Library) do
      maximum_frequency 44100
    end

    lambda {klass.new(frequency: 48000)}.must_raise Paula::InvalidFrequencyError
  end

  it "should be able to specify the supported extensions" do
    klass = Class.new(Paula::Library) do
      extensions ['foo', 'bar', 'baz']
    end

    klass.extensions.must_equal ['foo', 'bar', 'baz']
  end

  it "should be able to specify a single extension string" do
    klass = Class.new(Paula::Library) do
      extensions 'foo'
    end

    klass.extensions.must_equal ['foo']
  end

  it "should be able to report if it can play a file" do
    klass = Class.new(Paula::Library) do
      extensions ['foo']
    end

    assert klass.can_play?('file.foo')
    refute klass.can_play?('file.bar')
  end

  it "should also be able to figure out amiga-style filenames" do
    klass = Class.new(Paula::Library) do
      extensions ['mod']
    end

    assert klass.can_play?('mod.this_is_a_song')
    refute klass.can_play?('bar.this_is_a_song')
  end
end
