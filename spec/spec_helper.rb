require 'coveralls'
Coveralls.wear!

require 'active_interaction'

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }
