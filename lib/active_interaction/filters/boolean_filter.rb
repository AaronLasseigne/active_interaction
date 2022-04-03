# frozen_string_literal: true

module ActiveInteraction
  class Base # rubocop:disable Lint/EmptyClass
    # @!method self.boolean(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are Booleans. The strings `"1"`, `"true"`, and `"on"`
    #     (case-insensitive) are converted to `true` while the strings `"0"`,
    #     `"false"`, and `"off"` are converted to `false`. Blank strings are
    #     treated as a `nil` value.
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
    rescue NoMethodError # BasicObject
      false
    end

    def convert(value)
      if value.respond_to?(:to_str)
        value = value.to_str
        value = nil if value.blank?
      end

      case value
      when /\A(?:0|false|off)\z/i
        false
      when /\A(?:1|true|on)\z/i
        true
      else
        super
      end
    rescue NoMethodError # BasicObject
      super
    end
  end
end
