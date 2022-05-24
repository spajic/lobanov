# frozen_string_literal: true

module Lobanov
  # path is path_with_square_braces, like users/[user_id]/pets/[pet_id]
  class GenerateOperationId
    attr_reader :interaction

    def self.call(interaction)
      new(interaction).call
    end

    def initialize(interaction)
      @interaction = interaction
    end

    def call
      parts =
        path_parts_without_ids.map { |part| Support.camelize(part) } +
        [Support.camelize(interaction.controller_action)]
      parts.pop if parts[-1] == parts[-2] # /fruits/:id/reviews/:review_id/upvote
      parts.join
    end

    private

    def path_parts
      interaction.path_with_square_braces.split('/') - ['']
    end

    def path_parts_without_ids
      path_parts.reject { |part| part.start_with?('[') }
    end
  end
end
