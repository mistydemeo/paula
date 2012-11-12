require 'minitest/autorun'
require 'paula'

describe Paula do
  it "should be able to keep track of supported formats and libraries" do
    class Foo; end
    Paula.add_formats Foo, ['foo', 'bar']

    Paula.plays('foo').must_equal [Foo]
    Paula.plays('bar').must_equal [Foo]
  end
end
