# frozen_string_literal: true

module ActiveInteraction
  class Base
    # @!method self.boolean(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are Booleans. The strings `"1"`, `"true"`, and `"on"`
    #     (case-insensitive) are converted to `true` while the strings `"0"`,
    #     `"false"`, and `"off"` are converted to `false`.
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

    def matches?(value)
      value.is_a?(TrueClass) || value.is_a?(FalseClass)
    end

    def convert(value)
      case value
      when /\A(?:0|false|off)\z/i
        false
      when /\A(?:1|true|on)\z/i
        true
      else
        super
      end
    end
  end
end
