# frozen_string_literal: true

module ActiveInteraction
  # Raised if a user-supplied value to a nested hash input is invalid.
  class InvalidNestedValueError
    # @return [Symbol]
    attr_reader :filter_name

    # @return [Object]
    attr_reader :input_value

    # @param filter_name [Symbol]
    # @param input_value [Object]
    def initialize(filter_name, input_value)
      @filter_name = filter_name
      @input_value = input_value
    end

    def message
      "#{filter_name}: #{input_value.inspect}"
    end
  end

  # An extension that provides the ability to merge other errors into itself.
  class Errors < ActiveModel::Errors
    attr_accessor :backtrace

    # Merge other errors into this one.
    #
    # @param other [Errors]
    #
    # @return [Errors]
    def merge!(other)
      merge_details!(other)

      self
    end

    # @private
    def deindex_attribute(attribute)
      attribute.to_s.remove(/\[\d+\]/)
    end

    private

    def attribute?(attribute)
      @base.respond_to?(deindex_attribute(attribute))
    end

    def detailed_error?(detail)
      detail[:error].is_a?(Symbol)
    end

    def merge_message!(attribute, message)
      unless attribute?(attribute)
        message = full_message(attribute, message)
        attribute = :base
      end
      add(attribute, message) unless added?(attribute, message)
    end

    def merge_details!(other)
      other.messages.each do |attribute, messages|
        messages.zip(other.details[attribute]) do |message, detail|
          if detailed_error?(detail)
            merge_detail!(attribute, detail, message)
          else
            merge_message!(attribute, message)
          end
        end
      end
    end

    def merge_detail!(attribute, detail, message)
      if attribute?(attribute) || attribute == :base
        options = detail.dup
        error = options.delete(:error)

        add(attribute, error, **options.merge(message: message)) unless added?(attribute, error, **options)
      else
        merge_message!(attribute, message)
      end
    end
  end
end
