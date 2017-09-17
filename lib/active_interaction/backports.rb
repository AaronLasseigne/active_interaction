# frozen_string_literal: true

require 'active_support/core_ext'

module ActiveInteraction
  class Errors # rubocop:disable Style/Documentation
    # Required for Rails < 5.
    #
    # Extracted from active_model-errors_details 1.2.0. Modified to add support
    # for ActiveModel 3.2.0.
    module Details
      extend ActiveSupport::Concern

      CALLBACKS_OPTIONS = ::ActiveModel::Errors::CALLBACKS_OPTIONS
      private_constant :CALLBACKS_OPTIONS
      MESSAGE_OPTIONS = [:message].freeze
      private_constant :MESSAGE_OPTIONS

      included do
        attr_reader :details

        %w[initialize initialize_dup add clear delete].each do |method|
          alias_method_chain method, :details
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

        error = options.except(*CALLBACKS_OPTIONS + MESSAGE_OPTIONS)
          .merge(error: message)
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
    include Details unless method_defined?(:details)
  end
end
