require 'minitest/autorun'
require 'paula'

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
end
