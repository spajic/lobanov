# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lobanov::ValidateStoredSchema do
  let(:subject) do
    described_class.call(stored_schema: stored_schema, operation_id: 'OperationId')
  end

  context 'with nullable fields' do
    let(:stored_schema) do
      YAML.safe_load <<~YAML
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
            type: string
            nullable: true
          apps:
            type: object
            properties:
              tags:
                type: array
                minItems: 0
                uniqueItems: true
                example: []
              and_this_one_too:
                  nullable: true
      YAML
    end

    let(:missing_types) do
      ['properties->apps->and_this_one_too']
    end

    let(:missing_examples) do
      ['properties->this_key_will_be_missing', 'properties->apps->and_this_one_too']
    end

    let(:expected_errors) do
      {
        missing_types: missing_types,
        missing_examples: missing_examples
      }.inspect
    end

    it 'raises error for nullable property' do
      expected_error = <<~STRING
        Problem with OperationId

        Missing types:
        properties->apps->and_this_one_too

        Missing examples:
        properties->this_key_will_be_missing
        properties->apps->and_this_one_too
      STRING

      expect { subject }.to raise_error(Lobanov::MissingTypeOrExampleError, expected_error)
    end
  end
end
