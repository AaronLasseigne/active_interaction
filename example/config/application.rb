# coding: utf-8

require 'rails'

%w[
  action_controller
  action_view
  active_model
  active_record
].each { |framework| require "#{framework}/railtie" }

module Aire
  # Add interaction directories to the autoload path.
  class Application < Rails::Application
    config.autoload_paths += Dir.glob("#{config.root}/app/interactions/*")
  end
end
