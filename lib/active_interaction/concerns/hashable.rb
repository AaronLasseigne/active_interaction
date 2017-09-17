# frozen_string_literal: true

module ActiveInteraction
  # Allow `hash` to be overridden when given arguments and/or a block.
  #
  # @private
  module Hashable
    extend ActiveSupport::Concern

    def hash(*args, &block)
      if args.empty? && !block_given?
        super
      else
        method_missing(:hash, *args, &block)
      end
    end
  end
end
