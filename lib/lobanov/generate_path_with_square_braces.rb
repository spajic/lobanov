# frozen_string_literal: true

module Lobanov
  # users/:user_id/pets/:pet_id -> users/[user_id]/pets/[pet_id]
  class GeneratePathWithSquareBraces
    attr_reader :interaction

    def self.call(interaction)
      new(interaction).call
    end

    def initialize(interaction)
      @interaction = interaction
    end

    def call
      # res = endpoint_path.dup.gsub(%r{^/}, '') # убираем /, если строка начинается с него
      res = interaction.endpoint_path.dup
      ids = res.scan(/(:\w*)/).flatten # [':user_id', ':pet_id']
      ids.each do |id|
        res.gsub!(id, "[#{id.gsub(':', '')}]")
      end

      res.gsub('//', '/')
    end
  end
end
