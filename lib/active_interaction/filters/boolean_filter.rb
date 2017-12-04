# frozen_string_literal: true

module ActiveInteraction
  class Base
    # @!method self.boolean(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are Booleans. The strings `"1"` and `"true"`
    #     (case-insensitive) are converted to `true` while the strings `"0"`
    #     and `"false"` are converted to `false`.
    #
    #   @!macro filter_method_params
    #
    #   @example
    #     boolean :subscribed
  end

  # @private
  class BooleanFilter < Filter
    register :boolean

    def database_column_type
      self.class.slug
    end

    private

    def adjust_input(value)
      if value.respond_to?(:to_str)
        value = value.to_str
        value = nil if value.blank?
      end

      value
    end

    def matches?(value)
      value.is_a?(FalseClass) || value.is_a?(TrueClass)
    end

    def convert(value)
      case value
      when /\A(?:0|false|off)\z/i
        false
      when /\A(?:1|true|on)\z/i
        true
      else
        value
      end
    end
  end
end
