# coding: utf-8

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
    def cast(value)
      case value
      when FalseClass, '0', /\Afalse\z/i
        false
      when TrueClass, '1', /\Atrue\z/i
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
