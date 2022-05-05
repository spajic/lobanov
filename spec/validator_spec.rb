# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lobanov::Validator do
  let(:subject) do
    described_class.call(new_schema: new_schema, stored_schema: stored_schema)
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
