module ActiveInteraction
  # @private
  class ModelFilter < Filter
    def cast(value)
      case value
      when klass
        value
      else
        super
      end
    end

    private

    def klass
      name = options.fetch(:class, @name).to_s.classify
      name.constantize
    rescue NameError
      raise InvalidClass, name.inspect
    end
  end
end
