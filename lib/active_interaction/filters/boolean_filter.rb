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

    def cast(value, _interaction)
      case value
      when FalseClass, /\A(?:0|false|off)\z/i
        false
      when TrueClass, /\A(?:1|true|on)\z/i
        true
      else
        super
      end
    end

    def database_column_type
      self.class.slug
    end
  end
end
