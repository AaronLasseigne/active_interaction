module ActiveInteraction
  class ModelFilter < Filter
    # @param value [Object]
    #
    # @return [Object]
    #
    # @raise (see Filter#cast)
    def cast(value)
      case value
      when klass
        value
      else
        super
      end
    end

    private

    # @return [Class]
    #
    # @raise [Error]
    def klass
      name = @options.fetch(:class, @name).to_s.classify
      name.constantize
    rescue NameError
      raise InvalidClass, name.inspect
    end
  end
end
