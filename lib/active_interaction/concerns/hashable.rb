# coding: utf-8

module ActiveInteraction
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
