require 'minitest/autorun'
require 'paula/player'

describe Paula::Player do
  before do
    klass = Class.new(Paula::Player) { maximum_frequency 48000 }
    @player = klass.new '/path/to/file', frequency: 44100, loops: 1
  end

  it "should be able to define the maximum frequency" do
    klass = Class.new(Paula::Player) do
      maximum_frequency 44100
    end

    klass.maximum_frequency.must_equal 44100
  end

  it "should raise when an unsupported frequency is requested" do
    klass = Class.new(Paula::Player) do
      maximum_frequency 44100
    end

    lambda {klass.new('file', frequency: 48000)}.must_raise Paula::FrequencyError
  end

  it "should be able to specify the supported extensions" do
    klass = Class.new(Paula::Player) do
      extensions 'foo', 'bar', 'baz'
    end

    klass.extensions.must_equal ['foo', 'bar', 'baz']
  end

  it "should declare its extensions to Paula when created" do
    klass = Class.new(Paula::Player) do
      extensions 'unique'
    end

    Paula.plays('unique').must_equal [klass]
  end

  it "should be able to specify a single extension string" do
    klass = Class.new(Paula::Player) do
      extensions 'foo'
    end

    klass.extensions.must_equal ['foo']
  end

  it "should be able to report if it can play a file" do
    klass = Class.new(Paula::Player) do
      extensions 'foo'
    end

    assert klass.can_play?('file.foo')
    refute klass.can_play?('file.bar')
  end

  it "should also be able to figure out amiga-style filenames" do
    klass = Class.new(Paula::Player) do
      extensions 'mod'
    end

    assert klass.can_play?('mod.this_is_a_song')
    refute klass.can_play?('bar.this_is_a_song')
  end

  it "should be able to define whether titles are supported" do
    klass = Class.new(Paula::Player) do
      supports_title
    end

    assert klass.supports_title?
  end

  it "should be able to define whether comments are supported" do
    klass = Class.new(Paula::Player) do
      supports_comment
    end

    assert klass.supports_comment?
  end

  it "should be able to define whether instrument lists are supported" do
    klass = Class.new(Paula::Player) do
      supports_instruments
    end

    assert klass.supports_instruments?
  end

  it "should be able to define whether notes are supported" do
    klass = Class.new(Paula::Player) do
      supports_notes
    end

    assert klass.supports_notes?
  end

  it "should return nil as the default title" do
    @player.title.must_be_nil
  end

  it "should be able to return the player's filename" do
    @player.filename.must_equal 'file'
  end

  it "should be able to return the full path to the file" do
    @player.path.must_equal '/path/to/file'
  end

  it "should be able to report the playback frequency" do
    @player.frequency.must_equal 44100
  end

  it "should return nil as the default comment" do
    @player.comment.must_be_nil
  end

  it "should return 0 as the default duration" do
    @player.duration.must_equal 0
  end

  it "should return 0 as the default loop count" do
    @player.current_loop.must_equal 0
  end

  it "should return an empty string as the default sample" do
    @player.next_sample.must_equal ""
  end

  it "should report the sample size as 0 by default" do
    @player.sample_size.must_equal 0
  end

  it "should report the number of loops to play" do
    @player.loops_to_play.must_equal 1
  end

  it "should default to 0 channels" do
    @player.channels.must_equal 0
  end

  it "should always report that it is complete by default" do
    # because specific behaviour needs to be subclassed
    assert @player.complete?
  end

  it "should be enumerable" do
    @player.each.must_be_kind_of Enumerator
  end

  it "should raise when created without a frequency" do
    lambda {@player.class.new('file', loops: 1)}.must_raise Paula::FrequencyError
  end

  it "should default to one loop if not specified" do
    @player.class.new('file', frequency: 44100).loops_to_play.must_equal 1
  end
end
