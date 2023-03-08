# frozen_string_literal: true

module Lobanov
  class GenerateInteractionTags
    def self.call(interaction)
      parts = interaction.path_with_square_braces.split('/') - ['']
      Array(Support.camelize(parts.first))
    end
  end
end
