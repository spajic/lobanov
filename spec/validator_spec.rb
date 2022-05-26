# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lobanov::Validator do
  let(:subject) do
    described_class.call(new_schema: new_schema, stored_schema: stored_schema)
  end

  context 'with array with minItems: 0' do
    let(:stored_schema) do
      YAML.safe_load <<~YAML
        type: array
        uniqueItems: true
        minItems: 0
        items:
          type: object
          required:
            - email
            - provider
          properties:
            email:
              type: string
              example: fff@uuu.com
            provider:
              type: string
              example: facebook
      YAML
    end

    context 'when new_schema actually has items' do
      let(:new_schema) do
        YAML.safe_load <<~YAML
          type: array
          uniqueItems: true
          minItems: 1
          items:
            type: object
            required:
              - email
              - provider
            properties:
              email:
                type: string
                example: fff@uuu.com
              provider:
                type: string
                example: facebook
        YAML
      end

      it 'works without errors' do
        expect(subject).to eq(nil), subject
      end
    end

    context 'when new_schema has empty array' do
      let(:new_schema) do
        YAML.safe_load <<~YAML
          type: array
          minItems: 0
          uniqueItems: true
          items:
            example:
        YAML
      end

      it 'works without errors' do
        expect(subject).to eq(nil), subject
      end
    end
  end

  context 'with stored array with minItems: 1' do
    let(:stored_schema) do
      YAML.safe_load <<~YAML
        type: array
        uniqueItems: true
        minItems: 1
        items:
          type: object
          required:
            - email
            - provider
          properties:
            email:
              type: string
              example: fff@uuu.com
            provider:
              type: string
              example: facebook
      YAML
    end

    let(:new_schema) do
      YAML.safe_load <<~YAML
        type: array
        uniqueItems: true
        minItems: 0
        items:
          example:
      YAML
    end

    it 'returns error: do not allow empty array if stored minItems > 0' do
      expect { subject }.to raise_error(Lobanov::MissingRequiredFieldError)
    end
  end

  context 'with enum in stored schema' do
    let(:stored_schema) do
      YAML.safe_load <<~YAML
        type: object
        required: [sort_direction]
        properties:
          sort_direction:
            type: string
            enum:
              - asc
              - desc
            example: asc
          item:
            type: object
            properties:
              nested_enum:
                type: string
                example: one
                enum:
                  - one
                  - two
      YAML
    end

    let(:correct_new_schema) do
      YAML.safe_load <<~YAML
        type: object
        required: [sort_direction]
        properties:
          sort_direction:
            type: string
            example: asc
          item:
            type: object
            required: [nested_enum]
            properties:
              nested_enum:
                type: string
                example: one
      YAML
    end

    context 'when new schema is correct' do
      let(:new_schema) { correct_new_schema }

      it 'works without errors' do
        expect(subject).to eq(nil), subject
      end
    end

    context 'when new schema has value that does not belong to enum' do
      let(:new_schema) do
        YAML.safe_load <<~YAML
          type: object
          required: [sort_direction]
          properties:
            sort_direction:
              type: string
              example: FFF
            item:
              type: object
              required: [nested_enum]
              properties:
                nested_enum:
                  type: string
                  example: UUU
        YAML
      end

      it 'raises an error' do
        expected_msg =
          "Invalid enum value in new schema! properties->sort_direction. \n"\
          'Expected ["asc", "desc"], got "FFF"'
        expect { subject }.to raise_error(Lobanov::InvalidEnumError, expected_msg)
      end
    end

    context 'when stored schema is incorrect' do
      let(:stored_schema) do
        YAML.safe_load <<~YAML
          type: object
          required: [sort_direction]
          properties:
            sort_direction:
              type: string
              enum:
                - asc
                - desc
              example: FFFUUU
            item:
              type: object
              properties:
                nested_enum:
                  type: string
                  example: one
                  enum:
                    - one
                    - two
        YAML
      end

      let(:new_schema) { correct_new_schema }

      it 'raises an error' do
        expected_msg =
          "Invalid enum value in stored schema! properties->sort_direction. \n"\
          'Expected ["asc", "desc"], got "FFFUUU"'
        expect { subject }.to raise_error(Lobanov::InvalidEnumError, expected_msg)
      end
    end
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
            example: secret
          apps:
            type: object
            properties:
              tags:
                type: array
                minItems: 0
                uniqueItems: true
                items:
                  type: string
                  example:
                    - btc
                    - eth
                    - usdt
      YAML
    end

    context 'with actually null value' do
      let(:new_schema) do
        YAML.safe_load <<~YAML
          type: object
          required: [name]
          properties:
            name:
              type: string
              example: Alex
            rejection_comment:
              nullable: true
            apps:
              type: object
              properties:
                tags:
                  type: array
                  minItems: 0
                  uniqueItems: true
                  items: {}
        YAML
      end

      it 'returns no errors' do
        expect(subject).to eq(nil), subject
      end
    end

    context 'with actualy not null value' do
      let(:new_schema) do
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
              # nullable: true # генератор не догадается что поле nullable
            apps:
              type: object
              properties:
                tags:
                  type: array
                  minItems: 0
                  uniqueItems: true
                  items: {}
        YAML
      end

      it 'returns no errors' do
        expect(subject).to eq(nil), subject
      end
    end
  end

  context 'with nullable optional stored field and actual null' do
    let(:stored_schema) do
      YAML.safe_load <<~YAML
        type: object
        required:
          - surname
        properties:
          surname:
            type: string
            example: Ronaldo
            nullable: true
          name:
            type: string
            example: Nazario
            nullable: true
      YAML
    end

    let(:new_schema) do
      YAML.safe_load <<~YAML
        type: object
        required:
          - surname
        properties:
          surname:
            type: string
            example: Ronaldo
            nullable: true
      YAML
    end

    it 'works without errors' do
      expect(subject).to eq(nil), subject
    end
  end

  context 'with object with all nullable fields' do
    let(:stored_schema) do
      YAML.safe_load <<~YAML
        type: object
        required:
          - fio
        properties:
          fio:
            type: object
            required:
              - name
              - surname
            properties:
              name:
                type: string
                example: Alex
                nullable: true
              surname:
                type: string
                example: Vasilyev
                nullable: true
      YAML
    end

    let(:new_schema) do
      YAML.safe_load <<~YAML
        type: object
        required:
          - fio
        properties:
          fio:
            type: object
            required:
              - name
              - surname
            properties:
              name:
                nullable: true
              surname:
                nullable: true
      YAML
    end

    it 'allows to not have nullable property' do
      expect(subject).to eq(nil), subject
    end
  end
end
