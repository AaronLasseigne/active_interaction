module ActiveInteraction
  # @private
  class AbstractDateTimeCaster < Caster
    def self.prepare(key, value, options = {}, &block)
      klass = options.delete(:class)

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
            super
          end
        else
          super
      end
    end
  end
end
