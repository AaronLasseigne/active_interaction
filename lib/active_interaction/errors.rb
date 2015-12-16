# coding: utf-8

#
module ActiveInteraction
  # Top-level error class. All other errors subclass this.
  #
  # @return [Class]
  Error = Class.new(StandardError)

  # Raised if a class name is invalid.
  #
  # @return [Class]
  InvalidClassError = Class.new(Error)

  # Raised if a default value is invalid.
  #
  # @return [Class]
  InvalidDefaultError = Class.new(Error)

  # Raised if a filter has an invalid definition.
  #
  # @return [Class]
  InvalidFilterError = Class.new(Error)

  # Raised if an interaction is invalid.
  #
  # @return [Class]
  InvalidInteractionError = Class.new(Error)

  # Raised if a user-supplied value is invalid.
  #
  # @return [Class]
  InvalidValueError = Class.new(Error)

  # Raised if a filter cannot be found.
  #
  # @return [Class]
  MissingFilterError = Class.new(Error)

  # Raised if no value is given.
  #
  # @return [Class]
  MissingValueError = Class.new(Error)

  # Raised if there is no default value.
  #
  # @return [Class]
  NoDefaultError = Class.new(Error)

  # Raised if a reserved name is used.
  #
  # @return [Class]
  #
  # @since 1.2.0
  ReservedNameError = Class.new(Error)

  # Raised if a user-supplied value to a nested hash input is invalid.
  #
  # @return [Class]
  class InvalidNestedValueError < InvalidValueError
    # @return [Symbol]
    attr_reader :filter_name

    # @return [Object]
    attr_reader :input_value

    # @param filter_name [Symbol]
    # @param input_value [Object]
    def initialize(filter_name, input_value)
      super("#{filter_name}: #{input_value.inspect}")

      @filter_name = filter_name
      @input_value = input_value
    end
  end

  # An extension that provides the ability to merge other errors into itself.
  class Errors < ActiveModel::Errors
    # Merge other errors into this one.
    #
    # @param other [Errors]
    #
    # @return [Errors]
    def merge!(other)
      if other.respond_to?(:details)
        merge_details!(other)
      else
        merge_messages!(other)
      end

      self
    end

    private

    def merge_messages!(other)
      other.messages.each do |attribute, messages|
        messages.each do |message|
          unless attribute?(attribute)
            message = full_message(attribute, message)
            attribute = :base
          end
          add(attribute, message) unless added?(attribute, message)
        end
      end
    end

    def merge_details!(other)
      other.details.each do |attribute, details|
        details.each do |detail|
          detail = detail.dup
          error = detail.delete(:error)

          merge_detail!(other, attribute, detail, error)
        end
      end
    end

    def merge_detail!(other, attribute, detail, error)
      if attribute?(attribute)
        add(attribute, error, detail) unless added?(attribute, error, detail)
      else
        message = full_message(
          attribute, other.generate_message(attribute, error))
        attribute = :base
        add(attribute, message) unless added?(attribute, message)
      end
    end

    def attribute?(attribute)
      @base.respond_to?(attribute)
    end
  end
end
