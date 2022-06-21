# frozen_string_literal: true

module ActiveInteraction
  # Validates inputs using filters.
  #
  # @private
  module Validation
    class << self
      # @param context [Base]
      # @param filters [Hash{Symbol => Filter}]
      # @param inputs [Inputs]
      def validate(context, filters, inputs)
        filters.each_with_object([]) do |(name, filter), errors|
          input = filter.process(inputs[name], context)

          input.errors.each do |error|
            errors << [error.name, error.type, error.options]
          end
        end
      end
    end
  end
end
