require 'paula/core'
require 'paula/player'
require 'paula/songfile'
require "paula/version"

# FFI libraries raise a LoadError if the required dynamic library
# can't be loaded. We don't require that the user have the lib
# for every supported library, of course.
['paula/mdxmini', 'paula/pmdmini', 'paula/xmp', 'paula/uade'].each do |file|
  begin
    require file
  rescue LoadError
    next
  end
end
