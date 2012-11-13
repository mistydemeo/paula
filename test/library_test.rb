require 'minitest/autorun'
require 'paula/library'

describe Paula::Library do
  before do
    Paula.instance_variable_get(:@extensions).clear
  end

  it "should be able to declare a library via DSL method" do
    class LibraryTestClass
      class Player < Paula::Player
        extensions 'foo'
      end

      extend Paula::Library
      declare_library
    end

    Paula.plays('foo').must_equal [LibraryTestClass::Player]
  end
end
