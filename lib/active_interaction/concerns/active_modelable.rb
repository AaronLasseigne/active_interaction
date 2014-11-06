# coding: utf-8

module ActiveInteraction
  # Implement the minimal ActiveModel interface.
  #
  # @private
  module ActiveModelable
    extend ActiveSupport::Concern
    include ActiveModel::Model

    # @return (see ClassMethods#i18n_scope)
    #
    # @see ActiveModel::Translation#i18n_scope
    def i18n_scope
      self.class.i18n_scope
    end

    #
    module ClassMethods
      # @return [Symbol]
      #
      # @see ActiveModel::Translation#i18n_scope
      def i18n_scope
        :active_interaction
      end
    end
  end
end
