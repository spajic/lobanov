# frozen_string_literal: true

module Lobanov
  class LoadResponseSchema
    def self.call(interaction)
      schema_path = FindResponseForInteraction.call(interaction)
      return nil unless schema_path

      loaded_schema = YAML.load_file(schema_path)
      Lobanov::Support::ExpandRefs.call(
        loaded_schema,
        interaction.base_path.join('components/responses').to_s,
        registered_components: {}
      )
    end
  end
end
