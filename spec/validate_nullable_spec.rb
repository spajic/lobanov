# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lobanov::ValidateNullable do
  let(:subject) do
    described_class.call(stored_schema: stored_schema)
  end

  context 'with nullable fields' do
    let(:stored_schema) do
      YAML.load <<~YAML
        type: object
        required: [name]
        properties:
          name:
            type: string
            example: Alex
          rejection_comment:
            type: string
            example: rejected
            nullable: true
          this_key_will_be_missing:
            nullable: true
          apps:
            type: object
            properties:
              tags:
                type: array
                minItems: 0
                uniqueItems: true
              and_this_one_too:
                  nullable: true
      YAML
    end

    let(:expected_errors) do
      "properties->this_key_will_be_missing,\nproperties->apps->properties->and_this_one_too"
    end

    it 'raises error for nullable property' do
      expect{ subject }.to raise_error(Lobanov::MissingNotNullableValueError, expected_errors)
    end
  end
end
