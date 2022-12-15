# frozen_string_literal: true

module ActiveInteraction
  module Sugarable
    def composable(interaction, params = [], method: nil)
      method_name = method || interaction.to_s.gsub('::', '').underscore

      define_method method_name do
        compose(interaction, params.to_h { |p| [p, public_send(p)] })
      end
    end
  end
end
