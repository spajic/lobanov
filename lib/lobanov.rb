# frozen_string_literal: true

src = File.expand_path("../lobanov/*.rb", __FILE__)
files = Dir.glob(src).reject { |name| name.end_with?('lobanov/spec_helper.rb') }
files.each { |file| require file }

module Lobanov
  extend Configuration

  class LobanovError < StandardError; end

  class SchemaMismatchError < LobanovError; end

  class NonroutableRequestError < LobanovError; end

  class MissingExampleError < LobanovError; end

  class MissingRequiredFieldError < LobanovError; end

  class MissingNotNullableValueError < LobanovError; end

  class MissingTypeOrExampleError < LobanovError; end

  def self.capture(&block)
    Spy.on(&block)
  end

  def self.capture!(&block)
    Spy.on!(&block)
  end

  def self.handle_captured_interactions(interactions, overwrite: false)
    if ENV['FORCE_LOBANOV']
      overwrite = true
    end

    if interactions.size > 1
      raise LobanovError, 'Lobanov only supports one interaction per spec yet'
    end

    interaction = interactions.first
    repo = Repo.new(interaction: interaction)
    generator = Generator.new(interaction: interaction)
    stored_response_schema = LoadResponseSchema.new(
      path_with_curly_braces: generator.path_with_curly_braces,
      verb: generator.verb.downcase,
      status: generator.status.to_s
    ).call

    if overwrite || stored_response_schema.blank?
      repo.store_schema
    else
      new_schema = generator.call
      new_response_schema = new_schema.dig(
        'paths',
        generator.path_with_curly_braces,
        generator.verb.downcase,
        'responses',
        generator.status.to_s,
        'content',
        'application/json',
        'schema'
      )

      ValidateStoredSchema.call(stored_schema: stored_response_schema)
      error = Validator.call(new_schema: new_response_schema, stored_schema: stored_response_schema)
      return unless error

      raise SchemaMismatchError, build_error_message(interaction, error)
    end
  end

  def self.build_error_message(interaction, validation_error)
    interaction_name = "#{interaction.verb} #{interaction.endpoint_path}"
    "LOBANOV DETECTED SCHEMA MISMATCH!\n\n" \
      "Interaction '#{interaction_name}' failed! Schema changed:\n" \
      "#{validation_error}\n\n"
  end
end
