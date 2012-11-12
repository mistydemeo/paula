require 'minitest/autorun'
require 'paula/library'

describe Paula::Library do
  before do
    Paula.instance_variable_get(:@extensions).clear
  end

  it "should be able to declare a library via DSL method" do
    klass = Class.new do
      class Player < Paula::Player
        extensions 'foo'
      end

      extend Paula::Library
      declare_library
    end

    Paula.plays('foo').must_equal klass
  end
end
