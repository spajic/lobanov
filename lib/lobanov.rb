# frozen_string_literal: true

require 'lobanov/spec_helper'

module Lobanov
  class LobanovError < StandardError; end

  class SchemaMismatchError < LobanovError; end

  class NonroutableRequestError < LobanovError; end

  def self.capture(&block)
    Spy.on(&block)
  end

  def self.capture!(&block)
    Spy.on!(&block)
  end

  def self.handle_captured_interactions(interactions, overwrite: false)
    if interactions.size > 1
      raise LobanovError, 'Lobanov only supports one interaction per spec yet'
    end

    interaction = interactions.first
    repo = Repo.new(interaction: interaction)
    stored_schema = repo.load_schema

    if overwrite || stored_schema.blank?
      repo.store_schema
    else
      new_schema = Generator.new(interaction: interaction).call
      error = Validator.call(new_schema: new_schema, stored_schema: stored_schema)
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
