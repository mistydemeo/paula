require 'simplecov'

begin
  require 'simplecov-sublime-ruby-coverage'

  SimpleCov.formatter = SimpleCov::Formatter::SublimeRubyCoverageFormatter
rescue LoadError
end

SimpleCov.start
