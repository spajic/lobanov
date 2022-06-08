# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lobanov::Validator::ProcessNullable do
  let(:subject) do
    described_class.call(new_schema: new_schema, stored_schema: stored_schema)
  end

  context 'when all required props are present but nulls' do
    let(:stored_schema) do
      YAML.safe_load <<~YAML
        ---
        type: object
        required:
          - gtm_events
        properties:
          gtm_events:
            type: object
            required:
              - choose
              - confirm
            properties:
              choose:
                type: object
                nullable: true
                properties:
                  event_category:
                    type: string
                    example: My Plan
                  event_action:
                    type: string
                    example: Click
              confirm:
                type: object
                nullable: true
                properties:
                  event_category:
                    type: string
                    example: My Plan
                  event_action:
                    type: string
                    example: Click
      YAML
    end

    # по факту пришли значения choose: nil, confirm: nil
    let(:new_schema) do
      YAML.safe_load <<~YAML
        ---
        type: object
        required:
          - gtm_events
        properties:
          gtm_events:
            type: object
            required:
              - choose
              - confirm
            properties:
              choose:
                nullable: true
              confirm:
                nullable: true
      YAML
    end

    it 'works correctly' do
      expect(subject[:stored_schema]).to eq(subject[:new_schema])
    end
  end
end
