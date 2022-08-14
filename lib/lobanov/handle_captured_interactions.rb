# frozen_string_literal: true

require 'open3'

module Lobanov
  # Handles captured interactions
  class HandleCapturedInteractions
    def self.call(*params)
      new(*params).call
    end

    attr_reader :interactions, :overwrite

    def initialize(interactions, overwrite: false)
      @interactions = interactions
      @overwrite = overwrite
    end

    def call
      raise LobanovError, 'Lobanov only supports one interaction per spec yet' if interactions.size > 1

      if overwrite?
        repo.store_schema
        single_copy
      else
        ValidateStoredSchema.call(stored_schema: stored_response_schema, operation_id: interaction.operation_id)
        error = Validator.call(new_schema: new_response_schema, stored_schema: stored_response_schema)
        single_copy
        return unless error

        raise SchemaMismatchError, build_error_message(interaction, error)
      end
    end

    private

    def single_copy
      system "swagger-cli bundle #{Lobanov.index_path} -o #{Lobanov.specification_folder}/openapi_single.yaml --type yaml"
    end

    def overwrite?
      return true if ENV['FORCE_LOBANOV']

      overwrite || stored_response_schema.blank?
    end

    def interaction
      @interaction ||= interactions.first
    end

    def repo
      @repo ||= Repo.new(interaction: interaction)
    end

    def generator
      @generator ||= Generator.new(interaction: interaction)
    end

    def stored_response_schema
      @stored_response_schema ||= LoadResponseSchema.new(
        path_with_curly_braces: generator.path_with_curly_braces,
        verb: generator.verb.downcase,
        status: generator.status.to_s
      ).call
    end

    def new_schema
      @new_schema = generator.call
    end

    def new_response_schema
      @new_response_schema ||= new_schema.dig(
        'paths',
        generator.path_with_curly_braces,
        generator.verb.downcase,
        'responses',
        generator.status.to_s,
        'content',
        'application/json',
        'schema'
      )
    end

    def build_error_message(interaction, validation_error)
      interaction_name = "#{interaction.verb} #{interaction.endpoint_path}"
      "LOBANOV DETECTED SCHEMA MISMATCH!\n\n" \
        "Interaction '#{interaction_name}' failed! Schema changed:\n" \
        "#{validation_error}\n\n"
    end
  end
end
