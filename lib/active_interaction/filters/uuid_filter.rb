# coding: utf-8

module ActiveInteraction
  class Base
    # @!method self.string(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are UUIDs.
    #
    #   @example
    #     uuid :param_name
  end

  # @private
  class UUIDFilter < Filter
    register :uuid

    UUID_REGEXP = /^\h{8}-\h{4}-\h{4}-\h{4}-\h{12}$/

    def cast(value)
      case value
      when String, Symbol, Integer
        UUID_REGEXP.match(value.to_s) { |uuid| uuid[0] } ||
          (fail InvalidValueError, "Given value: #{value.inspect}")
      else
        super
      end
    end
  end
end
