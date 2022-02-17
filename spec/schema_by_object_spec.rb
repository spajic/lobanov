# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lobanov::SchemaByObject do
  let(:subject) { described_class.call(obj) }

  context 'with plain object' do
    let(:obj) do
      {
        'id' => 1,
        'name' => 'test bot'
      }
    end

    let(:expected_schema) do
      {
        'type' => 'object',
        'required' => %w[id name],
        'properties' => {
          'id' => {'type' => 'integer', 'example' => 1},
          'name' => {'type' => 'string', 'example' => 'test bot'}
        }
      }
    end

    it 'returns expected schema with examples' do
      expect(subject).to eq(expected_schema)
    end
  end

  context 'with nested object' do
    let(:obj) do
      {
        'bot' => {
          'id' => 1,
          'name' => 'test bot'
        }
      }
    end

    let(:expected_schema) do
      {
        'type' => 'object',
        'required' => ['bot'],
        'properties' => {
          'bot' => {
            'type' => 'object',
            'required' => %w[id name],
            'properties' => {
              'id' => {'type' => 'integer', 'example' => 1},
              'name' => {'type' => 'string', 'example' => 'test bot'}
            }
          }
        }
      }
    end

    it 'return expected schema with examples' do
      expect(subject).to eq(expected_schema)
    end
  end

  context 'with grid_bot response' do
    let(:obj) do
      {
        'bot' => {
          'id' => 1,
          'name' => 'test bot',
          'leverage_custom_value' => 0.123,
          'grid' => [
            {price: 51_716.94, side: :sell, amount: 0.15967494, order_placed: true},
            {price: 53_521.2, side: :sell, amount: 0.15967494, order_placed: true},
            {price: 49_912.67, side: nil, amount: 0.15967494, order_placed: false}
          ],
          'is_contract' => false
        }
      }
    end

    let(:expected_schema) do
      {
        'type' => 'object',
        'required' => ['bot'],
        'properties' => {
          'bot' => {
            'type' => 'object',
            'required' => %w[id name leverage_custom_value grid is_contract],
            'properties' => {
              'id' => {'type' => 'integer', 'example' => 1},
              'name' => {'type' => 'string', 'example' => 'test bot'},
              'leverage_custom_value' => {'type' => 'number', 'example' => 0.123},
              'grid' => {
                'type' => 'array',
                'minItems' => 1,
                'uniqueItems' => true,
                'items' => {
                  'type' => 'object',
                  'required' => %w[price amount],
                  'properties' => {
                    'price' => {'type' => 'number', 'example' => 51_716.94},
                    'side' => {'type' => 'string', 'example' => :sell},
                    'amount' => {'type' => 'number', 'example' => 0.15967494},
                    'order_placed' => {'type' => 'boolean', 'example' => true}
                  }
                }
              },
              'is_contract' => {'type' => 'boolean', 'example' => false}
            }
          }
        }
      }
    end

    it 'return expected schema with examples' do
      expect(subject).to eq(expected_schema)
    end
  end

  context 'with array' do
    let(:obj) do
      [
        {text: 'one'},
        {text: 'two'}
      ]
    end

    let(:expected_schema) do
      {
        'type' => 'array',
        'minItems' => 1,
        'uniqueItems' => true,
        'items' => {
          'type' => 'object',
          'required' => ['text'],
          'properties' => {
            'text' => {
              'type' => 'string',
              'example' => 'one'
            }
          }
        }
      }
    end

    it 'returns expected schema with examples' do
      expect(subject).to eq(expected_schema)
    end
  end

  context 'with array of arrays' do
    let(:obj) do
      [
        [1, 2, 3],
        [4, 5, 6]
      ]
    end

    let(:expected_schema) do
      {
        'type' => 'array',
        'minItems' => 1,
        'uniqueItems' => true,
        'items' => {
          'type' => 'array',
          'minItems' => 1,
          'uniqueItems' => true,
          'items' => {
            'type' => 'integer',
            'example' => 1
          }
        }
      }
    end

    it 'returns expected schema with examples' do
      expect(subject).to eq(expected_schema)
    end
  end
end
