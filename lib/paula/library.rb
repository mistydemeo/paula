require 'paula'

module Paula
  module Library
    def declare_library
      Paula.add_formats self.const_get(:Player), self.const_get(:Player).extensions
    end
  end
end
