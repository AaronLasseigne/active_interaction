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
  class InvalidNestedValueError < Error
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

  # Used by {Runnable} to signal a failure when composing.
  #
  # @private
  class Interrupt < Error
    attr_reader :outcome

    # @param outcome [Runnable]
    def initialize(outcome)
      super()

      @outcome = outcome
    end
  end
  private_constant :Interrupt

  # An extension that provides the ability to merge other errors into itself.
  class Errors < ActiveModel::Errors
    # Extracted from active_model-errors_details version 1.2.0. Modified to add
    # support for ActiveModel version 3.2.0.
    module Details
      extend ActiveSupport::Concern

      CALLBACKS_OPTIONS = ::ActiveModel::Errors::CALLBACKS_OPTIONS
      private_constant :CALLBACKS_OPTIONS

      included do
        attr_reader :details

        %w[initialize initialize_dup add clear delete].each do |method|
          alias_method "#{method}_without_details", method
          alias_method method, "#{method}_with_details"
        end
      end

      def initialize_with_details(base)
        @details = Hash.new { |details, attribute| details[attribute] = [] }
        initialize_without_details(base)
      end

      def initialize_dup_with_details(other)
        @details = other.details.deep_dup
        initialize_dup_without_details(other)
      end

      def add_with_details(attribute, message = :invalid, options = {})
        message = message.call if message.respond_to?(:call)
        error = options.except(*CALLBACKS_OPTIONS).merge(error: message)
        details[attribute].push(error)
        add_without_details(attribute, message, options)
      end

      def clear_with_details
        details.clear
        clear_without_details
      end

      def delete_with_details(attribute)
        details.delete(attribute)
        delete_without_details(attribute)
      end
    end

    include Details

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
          add(attribute, message) unless added?(attribute, message)
        end
      end
    end

    def merge_details!(other)
      other.details.each do |attribute, details|
        details.each do |detail|
          error = detail.delete(:error)
          add(attribute, error, detail) unless added?(attribute, error, detail)
        end
      end
    end
  end
end
