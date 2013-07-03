module ActiveInteraction
  module StringAttr
    DEFAULT_OPTIONS = {
      allow_nil: false
    }.freeze

    def self.prepare(value, options = {})
      options = DEFAULT_OPTIONS.merge(options)

      case value
        when String
          value
        when NilClass
          options[:allow_nil] ? nil : bad_value
        else
          bad_value
      end
    end

    def self.bad_value
      raise ArgumentError
    end
    private_class_method :bad_value
  end
end
