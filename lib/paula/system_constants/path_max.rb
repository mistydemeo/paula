require 'ffi'
require 'ffi/tools/const_generator'

module Paula
  module SystemConstants
    cg = FFI::ConstGenerator.new do |gen|
      gen.include 'limits.h'
      gen.const 'PATH_MAX'
    end
    # This constant is used by UADE in a few structs.
    PATH_MAX = cg['PATH_MAX'].to_i
  end
end
