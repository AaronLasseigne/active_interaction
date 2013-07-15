module ActiveInteraction
  # @private
  class AbstractDateTimeFilter < Filter
    def self.parse(klass, value, options)
      case value
        when klass
          value
        when String
          begin
            if options.has_key?(:format)
              klass.strptime(value, options[:format])
            else
              klass.parse(value)
            end
          rescue ArgumentError
            bad_value
          end
      end
    end
    private_class_method :parse
  end
end
