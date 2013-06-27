module ActiveInteraction
  module IntegerAttr
    DEFAULT_OPTIONS = {
      allow_nil: false
    }.freeze

    def self.prepare(value, options = {})
      options = DEFAULT_OPTIONS.merge(options)

      case value
        when Integer
          value
        when String
          begin
            Integer(value)
          rescue ArgumentError
            bad_value
          end
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
