module ActiveInteraction
  class DateTimeFilter < Filter
    # @param value [Object]
    #
    # @return [DateTime]
    #
    # @raise (see Filter#cast)
    def cast(value)
      case value
      when DateTime
        value
      when String
        begin
          if options.has_key?(:format)
            DateTime.strptime(value, options[:format])
          else
            DateTime.parse(value)
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
